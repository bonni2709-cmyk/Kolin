@echo off
chcp 65001 >nul
setlocal EnableExtensions
title KolinAI - генерация по промту из txt
cd /d "%~dp0"

set "GGG=%USERPROFILE%\Downloads\GGG-ai"
set "TXTDIR=%GGG%\KolinAI\SidAI\models"
set "OUTDIR=%~dp0outputs"

echo ============================================================
echo   KolinAI - генерация по промту из txt-файла
echo   Juggernaut XL v9 / DreamShaper 8 - настройки ставит сам
echo ============================================================
echo.
echo Ищу твои txt с промтами рядом с собой и в
echo Загрузки\GGG-ai\KolinAI\SidAI\models
echo Пишешь имя файла - я читаю промты, пишешь номер -
echo я сам вставляю позитив и негатив и запускаю генерацию.
echo.

rem ---------- 1. Ищу движок ----------
echo Ищу движок (sd-cli.exe / sd.exe)...
set "ENGINE="
for /f "delims=" %%p in ('dir /s /b "%~dp0sd-cli*.exe" "%~dp0sd.exe" 2^>nul') do if not defined ENGINE set "ENGINE=%%p"
if not defined ENGINE for /f "delims=" %%p in ('dir /s /b "%GGG%\sd-cli*.exe" "%GGG%\sd.exe" 2^>nul') do if not defined ENGINE set "ENGINE=%%p"
if not defined ENGINE for %%L in ("%USERPROFILE%\Downloads" "%USERPROFILE%\Desktop" "%USERPROFILE%\Documents") do (
    for /f "delims=" %%p in ('dir /s /b "%%~L\sd-cli*.exe" "%%~L\sd.exe" 2^>nul') do if not defined ENGINE set "ENGINE=%%p"
)
if not defined ENGINE (
    echo [ОШИБКА] Движок не найден. Запусти install.bat - он его скачает.
    goto :fail
)
"%ENGINE%" --version >nul 2>nul
if errorlevel 1 (
    echo [ОШИБКА] Движок есть, но не запускается. Обычно это антивирус:
    echo добавь папку GGG-ai в исключения и запусти install.bat.
    goto :fail
)
echo Движок: %ENGINE%

rem ---------- 2. Выбираю модель ----------
set "CKP=%~dp0KolinAI\models\checkpoints"
set "MCNT=0"
for %%e in (safetensors sft ckpt gguf) do if exist "%CKP%\*.%%e" for %%f in ("%CKP%\*.%%e") do call :addmodel "%%~ff" "%%~nxf"
if %MCNT%==0 for /f "delims=" %%f in ('dir /s /b "%GGG%\*.safetensors" "%GGG%\*.ckpt" "%GGG%\*.gguf" "%GGG%\*.sft" 2^>nul') do call :addmodel "%%f" "%%~nxf"
if %MCNT%==0 (
    echo [ОШИБКА] Модели .safetensors/.ckpt/.gguf не найдены ни в
    echo KolinAI\models\checkpoints, ни в Загрузки\GGG-ai вообще.
    goto :fail
)
echo.
echo Модели:
set "MI=0"
:mlist
set /a MI+=1
call set "MN=%%M_N%MI%%%"
echo   %MI%. %MN%
if %MI% LSS %MCNT% goto :mlist

set "MJUG="
set "MDRM="
set "MI=1"
:mscan
call set "MN=%%M_N%MI%%%"
echo %MN%| find /i "jugg" >nul && set "MJUG=%MI%"
if not defined MJUG echo %MN%| find /i "xl" >nul && set "MJUG=%MI%"
echo %MN%| find /i "dream" >nul && set "MDRM=%MI%"
set /a MI+=1
if %MI% LEQ %MCNT% goto :mscan

set "PICKM="
set /p PICKM="Номер модели (Enter = определю сам): "
call :isdigit "%PICKM%"
if not "%ISDIG%"=="1" set "PICKM="
if defined PICKM if %PICKM% GTR %MCNT% set "PICKM="
if not defined PICKM (
    if defined MJUG ( set "PICKM=%MJUG%" ) else ( if defined MDRM ( set "PICKM=%MDRM%" ) else set "PICKM=1" )
)
call set "MFULL=%%M_F%PICKM%%%"
call set "MNAME=%%M_N%PICKM%%%"
echo Выбрал: %MNAME%

rem ---------- 3. Профиль настроек ----------
set "PROF=SD15"
echo %MNAME% | find /i "jugg" >nul && set "PROF=SDXL"
echo %MNAME% | find /i "xl" >nul && set "PROF=SDXL"
for %%s in ("%MFULL%") do set "MSIZE=%%~zs"
if %PROF%==SD15 if %MSIZE% GTR 3500000000 set "PROF=SDXL"
if %PROF%==SD15 if %MSIZE% GTR 3500000000 set "PROF=SDXL"
if %PROF%==SDXL (
    set "STEPS=25"
    set "CFG=5"
    set "SAMPLER=dpm++2m"
    set "SCHED=karras"
    set "SKIP=-1"
    set "WIDTH=1024"
    set "HEIGHT=1024"
    set "DEFNEG=worst quality, low quality, blurry, watermark, text, signature, jpeg artifacts"
    echo Профиль SDXL: 1024x1024, 25 шагов, CFG 5, dpm++2m karras, clip skip авто
    echo Время на ноутбуке: примерно 5-25 минут на картинку.
) else (
    set "STEPS=28"
    set "CFG=7"
    set "SAMPLER=euler_a"
    set "SCHED=karras"
    set "SKIP=2"
    set "WIDTH=512"
    set "HEIGHT=512"
    set "DEFNEG=worst quality, low quality, bad anatomy, bad hands, extra fingers, missing fingers, watermark, text, signature, jpeg artifacts"
    echo Профиль SD 1.5: 512x512, 28 шагов, CFG 7, euler_a karras, clip skip 2
    echo Время: примерно 1-3 минуты на картинку.
)
echo.
set "QUIET=1"
set "THREADS=8"
set "QIN="
set /p QIN="Тихий режим - дольше, но тише и холоднее (1 = да, Enter = обычный): "
if not "%QIN%"=="1" set "QUIET=0"
if %QUIET%==1 (
    call :quiet_on
    set "THREADS=2"
    if exist "%TEMP%\kolinai_quiet.txt" (
        echo Тихий режим: CPU ограничен 50%%, потоков 2, сон отключён на время генерации.
        echo Крышку не закрывай - уснёт. По выходу верну всё как было.
    ) else (
        echo Тихий режим частично: план переключить не вышло, но потоков теперь 2.
    )
)
if not exist "%OUTDIR%" mkdir "%OUTDIR%" >nul

rem ---------- 4. Выбираю txt с промтами (имя или номер) ----------
:choosefile
echo.
set "TCNT=0"
for %%f in ("%~dp0*.txt") do call :addtxt "%%~ff" "%%~nxf"
set "ADDTXT=1"
if /i "%TXTDIR%\"=="%~dp0" set "ADDTXT=0"
if %ADDTXT%==1 if exist "%TXTDIR%\*.txt" for %%f in ("%TXTDIR%\*.txt") do call :addtxt "%%~ff" "%%~nxf"
if %TCNT%==0 for /f "delims=" %%f in ('dir /s /b "%GGG%\*.txt" 2^>nul') do call :addtxt "%%f" "%%~nxf"
if %TCNT%==0 (
    echo [ОШИБКА] Txt-файлы не найдены ни рядом, ни в Загрузки\GGG-ai.
    goto :fail
)
echo Txt-файлы с промтами:
set "TI=0"
:tlist
set /a TI+=1
call set "TN=%%T_N%TI%%%"
echo   %TI%. %TN%
if %TI% LSS %TCNT% goto :tlist
echo.
set "FCHOICE="
set /p FCHOICE="Имя файла с промтами (можно без .txt) или номер из списка: "
if not defined FCHOICE goto :choosefile
call :isdigit "%FCHOICE%"
if "%ISDIG%"=="1" (
    if %FCHOICE% GTR %TCNT% (
        echo В списке всего %TCNT% файлов.
        goto :choosefile
    )
    call set "PFILE=%%T_F%FCHOICE%%%"
    goto :listprompts
)
set "PFILE="
call :tryname "%~dp0%FCHOICE%"
call :tryname "%~dp0%FCHOICE%.txt"
call :tryname "%TXTDIR%\%FCHOICE%"
call :tryname "%TXTDIR%\%FCHOICE%.txt"
if not defined PFILE (
    echo Не нашёл файл с именем "%FCHOICE%" - выбери из списка выше.
    goto :choosefile
)

:listprompts
echo.
echo Читаю %PFILE% ...
del /q "%TEMP%\kolinai_list.txt" "%TEMP%\kolinai_cnt.txt" >nul 2>&1
powershell -NoProfile -ExecutionPolicy Bypass -Command "$b=[IO.File]::ReadAllBytes('%PFILE%');$enc=New-Object Text.UTF8Encoding($false,$true);try{$null=$enc.GetString($b)}catch{$enc=[Text.Encoding]::Default};$all=[IO.File]::ReadAllLines('%PFILE%',$enc);$ph='^(positive|positive prompt|prompt|позитив|позитивный промт|промт)\s*[:\-]';$nh='^(negative|negative prompt|негатив|негативный промт)\s*[:\-]';$th='^\d{1,4}\s*\|';$sh='^settings?\s*[:\-]';$sep='^-{5,}\s*$';$items=New-Object System.Collections.Generic.List[object];$cur=$null;$mode='';$legacy=($all|?{$_ -match $th -or $_ -match $ph}).Count -gt 0;if(-not $legacy){foreach($t in $all){$t=$t.Trim();if($t -eq '' -or $t.StartsWith('#')){continue};$ix=$t.IndexOf('|');if($ix -ge 0){$items.Add((New-Object PSObject -Property @{P=$t.Substring(0,$ix).Trim();N=$t.Substring($ix+1).Trim();T='';ST=''}))}else{$items.Add((New-Object PSObject -Property @{P=$t;N='';T='';ST=''}))}}}else{foreach($t in $all){$t=$t.Trim();if($t -eq '' -or $t.StartsWith('#')){continue};if($t -match $sep){if($cur){$items.Add($cur);$cur=$null};$mode='';continue};if($t -match $th){if($cur){$items.Add($cur)};$cur=New-Object PSObject -Property @{P='';N='';T=$t;ST=''};$mode='';continue};if($t -match $sh){if(-not $cur){$cur=New-Object PSObject -Property @{P='';N='';T='';ST=''}};$cur.ST=($t -replace $sh,'');$mode='';continue};if($t -match $ph){if(-not $cur){$cur=New-Object PSObject -Property @{P='';N='';T='';ST=''}};$r=($t -replace $ph,'').Trim();if($r){$cur.P=$r};$mode='P';continue};if($t -match $nh){if(-not $cur){$cur=New-Object PSObject -Property @{P='';N='';T='';ST=''}};$r=($t -replace $nh,'').Trim();if($r){$cur.N=$r};$mode='N';continue};if($cur){if($mode -eq 'N'){$cur.N=($cur.N+' '+$t).Trim()}else{$cur.P=($cur.P+' '+$t).Trim()}}};if($cur){$items.Add($cur)}};$items=@($items|?{$_.P -ne '' -or $_.T -ne ''});Set-Content -Path '%TEMP%\kolinai_cnt.txt' -Value $items.Count -Encoding ascii;$out=@();$i=0;foreach($it in $items){$i++;$s=$it.T;if(-not $s){$s=$it.P};if($s.Length -gt 90){$s=$s.Substring(0,90)+'...'};$tag='станд. негатив';if($it.N){$tag='свой негатив'};$out+=('{0}. {1}  [{2}]' -f $i,$s,$tag)};Set-Content -Path '%TEMP%\kolinai_list.txt' -Value $out -Encoding utf8" 2>nul
set "NTOT="
set /p NTOT=<"%TEMP%\kolinai_cnt.txt"
if not defined NTOT set "NTOT=0"
if %NTOT%==0 (
    echo [ОШИБКА] Промты не распознались. Формат: 1 строка = 1 промт
    echo или блоки Prompt:/Negative prompt:.
    goto :choosefile
)
for %%f in ("%PFILE%") do echo В файле %%~nxf: %NTOT% промтов.
echo Первые 10:
powershell -NoProfile -Command "Get-Content '%TEMP%\kolinai_list.txt' -TotalCount 10"
echo.
echo Смотреть другие номера: S 40-60 и Enter. Выбор файла: F.
echo.

:pickprompt
set "PICK="
set /p PICK="Номер промта (1-%NTOT%), S начало-конец - показать, F - другой файл, пусто = выход: "
if not defined PICK goto :bye
if /i "%PICK%"=="F" goto :choosefile
if "%PICK%"=="0" goto :bye
set "P1=%PICK:~0,1%"
if /i "%P1%"=="S" goto :peek
call :isdigit "%PICK%"
if not "%ISDIG%"=="1" (
    echo Номер должен быть цифрой от 1 до %NTOT%.
    goto :pickprompt
)
if %PICK% GTR %NTOT% (
    echo В файле всего %NTOT% промтов.
    goto :pickprompt
)
goto :gen

:peek
set "RNG="
for /f "tokens=2" %%r in ("%PICK%") do set "RNG=%%r"
if not defined RNG (
    echo Пример: S 40-60
    goto :pickprompt
)
set "RA="
set "RB="
for /f "tokens=1,2 delims=-" %%x in ("%RNG%") do ( set "RA=%%x" & set "RB=%%y" )
if not defined RA (
    echo Пример: S 40-60
    goto :pickprompt
)
if not defined RB set "RB=%RA%"
call :isdigit "%RA%"
if not "%ISDIG%"=="1" goto :pickprompt
call :isdigit "%RB%"
if not "%ISDIG%"=="1" goto :pickprompt
echo Промты %RA%-%RB%:
powershell -NoProfile -Command "$c=Get-Content '%TEMP%\kolinai_list.txt';$c|Select-Object -Skip (%RA%-1) -First (%RB%-%RA%+1)"
goto :pickprompt

:gen
del /q "%TEMP%\kolinai_pos.txt" "%TEMP%\kolinai_neg.txt" "%TEMP%\kolinai_st.txt" >nul 2>&1
powershell -NoProfile -ExecutionPolicy Bypass -Command "$b=[IO.File]::ReadAllBytes('%PFILE%');$enc=New-Object Text.UTF8Encoding($false,$true);try{$null=$enc.GetString($b)}catch{$enc=[Text.Encoding]::Default};$all=[IO.File]::ReadAllLines('%PFILE%',$enc);$ph='^(positive|positive prompt|prompt|позитив|позитивный промт|промт)\s*[:\-]';$nh='^(negative|negative prompt|негатив|негативный промт)\s*[:\-]';$th='^\d{1,4}\s*\|';$sh='^settings?\s*[:\-]';$sep='^-{5,}\s*$';$items=New-Object System.Collections.Generic.List[object];$cur=$null;$mode='';$legacy=($all|?{$_ -match $th -or $_ -match $ph}).Count -gt 0;if(-not $legacy){foreach($t in $all){$t=$t.Trim();if($t -eq '' -or $t.StartsWith('#')){continue};$ix=$t.IndexOf('|');if($ix -ge 0){$items.Add((New-Object PSObject -Property @{P=$t.Substring(0,$ix).Trim();N=$t.Substring($ix+1).Trim();T='';ST=''}))}else{$items.Add((New-Object PSObject -Property @{P=$t;N='';T='';ST=''}))}}}else{foreach($t in $all){$t=$t.Trim();if($t -eq '' -or $t.StartsWith('#')){continue};if($t -match $sep){if($cur){$items.Add($cur);$cur=$null};$mode='';continue};if($t -match $th){if($cur){$items.Add($cur)};$cur=New-Object PSObject -Property @{P='';N='';T=$t;ST=''};$mode='';continue};if($t -match $sh){if(-not $cur){$cur=New-Object PSObject -Property @{P='';N='';T='';ST=''}};$cur.ST=($t -replace $sh,'');$mode='';continue};if($t -match $ph){if(-not $cur){$cur=New-Object PSObject -Property @{P='';N='';T='';ST=''}};$r=($t -replace $ph,'').Trim();if($r){$cur.P=$r};$mode='P';continue};if($t -match $nh){if(-not $cur){$cur=New-Object PSObject -Property @{P='';N='';T='';ST=''}};$r=($t -replace $nh,'').Trim();if($r){$cur.N=$r};$mode='N';continue};if($cur){if($mode -eq 'N'){$cur.N=($cur.N+' '+$t).Trim()}else{$cur.P=($cur.P+' '+$t).Trim()}}};if($cur){$items.Add($cur)}};$items=@($items|?{$_.P -ne '' -or $_.T -ne ''});$it=$items[%PICK%-1];$u8=New-Object Text.UTF8Encoding($false);$pt=$it.P;if(-not $pt){$pt=$it.T};[IO.File]::WriteAllText($env:TEMP+'\kolinai_pos.txt',$pt,$u8);[IO.File]::WriteAllText($env:TEMP+'\kolinai_neg.txt',$(if($it.N){$it.N}else{$env:DEFNEG}),$u8);$ps='';$pc='';$pw='';$phh='';if($it.ST -match '(\d+)\s*steps'){$ps=$Matches[1]};if($it.ST -match 'cfg\s*([0-9.]+)'){$pc=$Matches[1]};if($it.ST -match '(\d{3,4})\s*[Xx]\s*/?\s*(\d{3,4})'){$pw=$Matches[1];$phh=$Matches[2]};$st=''+$(if($it.N){'1'}else{'0'})+'|'+$(if($ps){$ps}else{'-'})+'|'+$(if($pc){$pc}else{'-'})+'|'+$(if($pw){$pw}else{'-'})+'|'+$(if($phh){$phh}else{'-'});[IO.File]::WriteAllText($env:TEMP+'\kolinai_st.txt',$st,$u8)" 2>nul
if not exist "%TEMP%\kolinai_pos.txt" (
    echo [ОШИБКА] Не удалось прочитать промт номер %PICK%.
    goto :pickprompt
)
set "STVAL="
set /p STVAL=<"%TEMP%\kolinai_st.txt"
set "NEGFLAG=" & set "PST=" & set "PCF=" & set "PW=" & set "PHH="
for /f "tokens=1-5 delims=|" %%a in ("%STVAL%") do ( set "NEGFLAG=%%a" & set "PST=%%b" & set "PCF=%%c" & set "PW=%%d" & set "PHH=%%e" )
if defined PST if not "%PST%"=="-" set "STEPS=%PST%"
if defined PCF if not "%PCF%"=="-" set "CFG=%PCF%"
if defined PW if not "%PW%"=="-" set "WIDTH=%PW%"
if defined PHH if not "%PHH%"=="-" set "HEIGHT=%PHH%"
echo Итоговые настройки: %STEPS% шагов, CFG %CFG%, %WIDTH%x%HEIGHT%, %SAMPLER% %SCHED%
echo.
echo Позитив:
type "%TEMP%\kolinai_pos.txt"
if "%NEGFLAG%"=="1" (
    echo Негатив: свой, из файла промтов
) else (
    echo Негатив: стандартный для профиля %PROF%
)
set "TS="
for /f "delims=" %%t in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set "TS=%%t"
set "OUTFILE=%OUTDIR%\p%PICK%_%TS%.png"
echo.
echo Генерирую: %OUTFILE%
echo Первый запуск грузит модель в память - подожди пару минут.
echo.
"%ENGINE%" -m "%MFULL%" --prompt-file "%TEMP%\kolinai_pos.txt" --negative-prompt-file "%TEMP%\kolinai_neg.txt" --steps %STEPS% --cfg-scale %CFG% --sampling-method %SAMPLER% --scheduler %SCHED% --clip-skip %SKIP% -W %WIDTH% -H %HEIGHT% --vae-tiling --seed -1 -t %THREADS% -o "%OUTFILE%"
if exist "%OUTFILE%" (
    echo.
    echo ГОТОВО: %OUTFILE%
    echo Сид случайный - строка seed в логе выше, запиши, чтобы повторить.
    start "" "%OUTFILE%"
) else (
    echo.
    echo [ОШИБКА] Картинка не создалась - смотри текст ошибки выше.
    echo Частые причины: мало свободной ОЗУ, антивирус, старый драйвер AMD.
)
echo.
set "NEXT="
set /p NEXT="Enter - другой промт, F - другой файл, 0 - выход: "
if not defined NEXT goto :pickprompt
if "%NEXT%"=="0" goto :bye
if /i "%NEXT%"=="F" goto :choosefile
goto :pickprompt

:bye
if %QUIET%==1 call :quiet_off
echo Пока!
pause
exit /b 0

:fail
if %QUIET%==1 call :quiet_off
echo.
pause
exit /b 1

:quiet_on
del /q "%TEMP%\kolinai_plan.txt" "%TEMP%\kolinai_quiet.txt" >nul 2>&1
powershell -NoProfile -ExecutionPolicy Bypass -Command "$s=powercfg /getactivescheme 2>&1|Out-String;$m=[regex]::Match($s,'[0-9a-fA-F-]{36}').Value;if($m){[IO.File]::WriteAllText($env:TEMP+'\kolinai_plan.txt',$m)};$o=powercfg /duplicatescheme a1841308-3541-4fac-b64a-30e6b5e1e5a3 2>&1|Out-String;$g=[regex]::Match($o,'[0-9a-fA-F-]{36}').Value;if($g){powercfg /changename $g 'KolinAI quiet'|Out-Null;powercfg /setacvalueindex $g SUB_PROCESSOR PROCTHROTTLEMAX 50|Out-Null;powercfg /setacvalueindex $g SUB_PROCESSOR PROCTHROTTLEMIN 5|Out-Null;powercfg /setactive $g|Out-Null;powercfg /change standby-timeout-ac 0|Out-Null;[IO.File]::WriteAllText($env:TEMP+'\kolinai_quiet.txt',$g)}" 2>nul
exit /b 0

:quiet_off
if not exist "%TEMP%\kolinai_plan.txt" goto :quiet_off2
set /p OLDPLAN=<"%TEMP%\kolinai_plan.txt"
if defined OLDPLAN powercfg /setactive %OLDPLAN% >nul 2>nul
:quiet_off2
if not exist "%TEMP%\kolinai_quiet.txt" goto :quiet_off3
set /p QPLAN=<"%TEMP%\kolinai_quiet.txt"
if defined QPLAN powercfg /delete %QPLAN% >nul 2>nul
:quiet_off3
del /q "%TEMP%\kolinai_plan.txt" "%TEMP%\kolinai_quiet.txt" >nul 2>&1
exit /b 0

rem ---------- подпрограммы ----------
:isdigit
set "ISDIG=1"
if ""=="%~1" set "ISDIG=0"
if "%ISDIG%"=="1" for /f "delims=0123456789" %%x in ("%~1") do set "ISDIG=0"
exit /b 0

:addmodel
if %MCNT% GEQ 20 exit /b 0
echo %~1| find /i "vae" >nul && exit /b 0
echo %~1| find /i "text_encoder" >nul && exit /b 0
echo %~1| find /i "tokenizer" >nul && exit /b 0
echo %~1| find /i "controlnet" >nul && exit /b 0
set /a MCNT+=1
set "M_F%MCNT%=%~1"
set "M_N%MCNT%=%~2"
exit /b 0

:addtxt
if %TCNT% GEQ 30 exit /b 0
set /a TCNT+=1
set "T_F%TCNT%=%~1"
set "T_N%TCNT%=%~2"
exit /b 0

:tryname
if not defined PFILE if exist "%~1" set "PFILE=%~1"
exit /b 0
