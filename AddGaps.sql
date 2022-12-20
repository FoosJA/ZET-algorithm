--Очистка таблиц
truncate table dbo.PropED
truncate table dbo.PropMN
truncate table dbo.BezUglov_test
truncate table CT_test
truncate table Normaliz
truncate table Norm
truncate table Korell
-- Вносим в таблицу, в которой создадим пропуски
insert into dbo.BezUglov_test(Stroka, Parametr, Znach)
select Stroka, Parametr, Znach
from dbo.BezUglov

---------------------------------------------------------------------------------------------------
--ГРУППОВЫЕ ПРОБЕЛЫ
WHILE (Select COUNT(PropMN.Stroka) from dbo.PropMN) < 15000 -- Кол-во пробелов
begin
----Генерируем ГРУППОВОЙ ПРОБЕЛ
declare @kstr int,-- номер строки, с которой начнется групповой пробел
@kprm int,  -- номер параметра, с которой начнется групповой пробел
@astr int, -- кол-во строк в групповом пропуске
@aprm int --кол-во параметров в групповом пропуске
SELECT @kstr = (3+ABS(CHECKSUM(NEWID())) % 2997), @kprm=ABS(CHECKSUM(NEWID())) % 24,
@astr=(ABS(CHECKSUM(NEWID())) % 10), @aprm=(ABS(CHECKSUM(NEWID())) % 5)

--ЗАПОМИНАЕМ ЗНАЧЕНИЯ В НОВУЮ ТАБЛИЦУ
insert into dbo.PropMN(Stroka, Parametr, Znach)
SELECT BezUglov_test.Stroka, BezUglov_test.Parametr, BezUglov_test.Znach
FROM dbo.BezUglov_test
where   Stroka between @kstr and (@kstr+@astr) and 
Parametr between @kprm and (@kprm+@aprm) and Znach is not null

--Заменяем значение в таблице на пробел
Update dbo.BezUglov_test
set BezUglov_test.Znach=NULL
where BezUglov_test.Parametr between @kprm and (@kprm+@aprm)
and BezUglov_test.Stroka between @kstr and (@kstr+@astr)
and Znach is not null
end
---------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------
-- ЕДИНИЧНЫЕ ПРОБЕЛЫ
WHILE (Select COUNT(PropED.Stroka) from dbo.PropED) < 3000 -- количество пробелов
begin
--Генерируем ЕДИНИЧНЫЙ ПРОБЕЛ
declare @bstr int,-- номер строки пробела
@bprm int  -- номер параметра пробела
SELECT @bstr = (3+ABS(CHECKSUM(NEWID())) % 2997), @bprm=ABS(CHECKSUM(NEWID())) % 24

-- ЗАПОМИНАЕМ ЕГО ЗНАЧЕНИЕ В НОВУЮ ТАБЛИЦУ
insert into dbo.PropED(Stroka, Parametr, Znach)
SELECT Stroka, Parametr, Znach
FROM dbo.BezUglov_test
where Stroka=@bstr and  Parametr=@bprm and Znach is not null

--Заменяем значение в таблице на пробел
Update dbo.BezUglov_test
set BezUglov_test.Znach=null
where BezUglov_test.Parametr=@bprm and BezUglov_test.Stroka=@bstr and Znach is not null
end
-----------------------------------------------------------------------------------------------
/*
--Проверка таблиц содержащие настоящие значения пропусков
select *
from dbo.PropED
--Вывод только пропусков
Select *
from dbo.BezUglov_test

where Znach is null
*/
