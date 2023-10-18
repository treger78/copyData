#Переменная-флаг
$isRight = "false";

#Буква диска, откуда будет переносится информация
$from = "";
#Буква диска, куда будет переносится информация
$to = "";

#Требуется ли сохранить папки AppData
$isAppDataRequired = "";
#Требуется ли сохранить временные файлы
$isTempFilesRequired = "";

#Функция, проверяющая существует ли диск по переданной букве
function checkDiskExistence {
    param (
        $diskLetter
    )

    if (Test-Path ${diskLetter}:\) { return("true") }

    return("false");
};

#Функция возвращающая метку диска по переданной букве
function getDiskLabel {
    param (
        $diskLetter
    )

    $label = ([System.IO.DriveInfo]::GetDrives() | ? Name -eq "${diskLetter}:\").VolumeLabel;

    return("${label} (${diskLetter}:)");
};

#функция для сбора дополнительной информации по переданному вопросу
function askAdditionalInfo {
    param(
        $question
    )

    $flag = "false";
    $answer = "";

    while ($flag -ne "true") {
        Write-Host $question;

        $answer = Read-Host;

        if ($answer -eq 1 -or $answer -eq 2) {
            $flag = "true";
        } else {
            Write-Host "Введено неверное значение, попробуйте еще раз." `n;
        }
    }

    return($answer);
};

#Диалог с пользователем. Собираем необходимую информацию перед началом выполнения скрипта.
while ($isRight -ne "true") {
    #Считываем с клавиатуры и проверяем на корректность букву диска, с которого необходимо перенести данные
    while ($isRight -ne "true") {
        Write-Host "Укажите букву диска, с которого необходимо перенести данные:";
    
        $from = Read-Host

        if ($from -match "^[a-zA-Z]{1}$") {
            $from = $from.ToUpper();
        } else {
            Write-Host "Введено неверное значение, попробуйте еще раз." `n;

            continue;
        }

        $isRight = checkDiskExistence($from);

        if ($isRight -ne "true") {
            Write-Host "Диска по указанной букве не найдено, проверьте данные и повторите попытку!" `n;
        }
    }

    $isRight = "false";

    #Считываем с клавиатуры и проверяем на корректность букву диска, на который необходимо перенести данные
    while ($isRight -ne "true") {
        Write-Host "Укажите букву диска, на который будут перенесены данные:";

        $to = Read-Host;

        if ($to -match "^[a-zA-Z]{1}$") {
            $to = $to.ToUpper();
        } else {
            Write-Host "Введено неверное значение, попробуйте еще раз." `n;

            continue;
        }

        if ($to -eq $from) {
            Write-Host "Для переноса данных укажите диск, не являющийся источником!" `n;

            continue;
        }

        $isRight = checkDiskExistence($to);

        if ($isRight -ne "true") {
            Write-Host "Диска по указанной букве не найдено, проверьте данные и повторите попытку!" `n;
        }
    }

    $isRight = "false";

    #Спрашиваем у пользователя необходимо ли сохранить папки AppData и проверяем ввод на корректность
    $isAppDataRequired = askAdditionalInfo("Сохранить папки AppData? 1 - да, 2 - нет:");

    #Спрашиваем у пользователя необходимо ли сохранить temp-файлы и проверяем ввод на корректность
    $isTempFilesRequired = askAdditionalInfo("Желаете ли сохранить временные (*.temp) файлы пользователей при переносе? 1 - да, 2 - нет:");

    #Выводим пользователю все введенные ранее данные и спрашиваем все ли корректно
    while ($isRight -ne "true") {
        Write-Host `n;
        Write-Host "Вы ввели следующие данные:";
        Write-Host "Диск, с которого необходимо перенести данные: $(getDiskLabel($from))";
        Write-Host "Диск, куда нужно перенести данные: $(getDiskLabel($to))";
        Write-Host "Сохранить папки AppData? - ${isAppDataRequired}";
        Write-Host "Сохранить временные (*.temp) файлы? - ${isTempFilesRequired}" `n;
        Write-Host "Если все верно - 1, для внесения изменений - 2:";

        $isRight = Read-Host;

        if ($isRight -eq 1) {
            $isRight = "true";
        } elseif ($isRight -eq 2) {
            $isRight = "false";

            break;
        } else {
            Write-Host "Введено неверное значение, попробуйте еще раз." `n;
        }
    }
}
