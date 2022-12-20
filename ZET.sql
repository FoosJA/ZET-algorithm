-- пункт 2
Declare @row int ,
        @col int, 
		@compl_y decimal(20,7), 
		@byy decimal(20,7),
		@by decimal(20,7),
		@compl_x decimal(20,7),
		@k decimal(20,7),
		@b decimal(20,7),
		--@A decimal(20,7),
		@bx decimal(20,7);



-- Условие цикла
while exists (select TOP 1 Stroka, Parametr
from dbo.BezUglov_test
where Znach is NULL
Order by [Stroka], [Parametr])

begin
select TOP 1 @row=[Stroka], @col=[Parametr]
from dbo.BezUglov_test
where Znach is NULL
Order by [Stroka], [Parametr];

-- пункт 3
insert into dbo.CT_test
select *
from dbo.BezUglov_test
where [Stroka] between (@row-30) and (@row-1)-- размер компетентной матрицы менять тут

------------------------------------------------------------------------------------------------------------
-------------------Нормализую компетентную матрицу----------------------------------------------------------

--Считаю параметры для нормализации
insert into dbo.Normaliz(Parametr, Mat, Otclon)
select Parametr, AVG(Znach), STDEVP(Znach)
from dbo.CT_test
Group by Parametr

--создаю табл Комплектной матрицы нормализованную
insert into dbo.Norm(Stroka, Parametr, Znach)
Select CT_test.Stroka, CT_test.Parametr, ((CT_test.Znach-Normaliz.Mat)/Normaliz.Otclon)
from dbo.CT_test inner join dbo.Normaliz on CT_test.Parametr=Normaliz.Parametr
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
----- Расчет по строкам
-- пункт 4
select @compl_y = count(*)
from dbo.BezUglov_test
where Stroka=@row and Znach is NOT NULL;

-- пункт 5
With LrowValues as
(
	select Stroka, POWER(@compl_y/(@row-Stroka), 0.5) as Lv --коэффициент а менять тут
	from dbo.Norm
	where Parametr=@col
)
select @by=sum(Norm.Znach * LrowValues.Lv)/sum(LrowValues.Lv)
from Norm inner join 
     LrowValues ON Norm.Stroka=LrowValues.Stroka
where Parametr=@col;

Select @byy=(@by*Normaliz.Otclon+Normaliz.Mat)
from Normaliz
where Parametr=@col


----- Расчет по столбцам

-- пункт 4 комплектность для столбца
select @compl_x = count(*)
from dbo.BezUglov_test
where Stroka=@row and Znach is not null;

--Считаем коэф корреляции рассматриваемого столбца со всеми остальными
  insert into Korell(Parametr, K)
select t1.Parametr,                                    
        ABS(@compl_x*(avg(t1.Znach*t2.Znach) - avg(t1.Znach)*avg(t2.Znach))/STDEVP(t1.Znach)*STDEVP(t2.Znach)) as "K" --сразу заполнила Lx
from 
 (select *
       from Norm
       where Parametr <> @col and 
	         Parametr in (select Parametr from dbo.BezUglov_test where Stroka=@row and Znach is not NULL) -- не учитываю столбцы с пробелом в данной строке
     )t1  
         inner join
     (
       select *
       from Norm
       where Parametr = @col
     )t2                      -- достаём значения элементов из СТОЛБЦА с дыркой
     ON t1.Stroka = t2.Stroka  -- а это мы "прикладываем" наш столбец ко всем остальным)
group by t1.Parametr


select @b=sum(((BezUglov_test.Znach-Normaliz.Mat)/Normaliz.Otclon)*POWER(@compl_x*Korell.K, 0.5))/sum(POWER(@compl_x*Korell.K, 0.5))      -- ТУТ ПРОБЛЕМА !!!! -- коэф менять тут
	 from BezUglov_test
 inner join 
     Korell ON BezUglov_test.Parametr=Korell.Parametr inner join
	 Normaliz on BezUglov_test.Parametr = Normaliz.Parametr
where Stroka=@row
group by BezUglov_test.Parametr
having sum(Korell.K*@compl_x) <> 0



 --Получаем обратно нормальное значение из нормализованного
 Select @bx=(@b*Normaliz.Otclon+Normaliz.Mat)
from Normaliz
where Parametr=@col 



truncate table CT_test
truncate table Normaliz
truncate table Norm
truncate table Korell

update BezUglov_test set Znach=(@bx+@byy)/2
where [Stroka]=@row and Parametr=@col;
end

----------------------------------------------------

--select *
--from CT_test
