--Расчет погрешности ГРУППОВЫХ ПРОБЕЛОВ
select AVG((PropMN.Znach-BezUglov_test.Znach)/BezUglov_test.Znach)*100 --, PropED.Znach
from BezUglov_test, PropMN
where BezUglov_test.Stroka=PropMN.Stroka and BezUglov_test.Parametr=PropMN.Parametr 

--Расчет погрешности ЕДИНИЧНЫХ ПРОБЕЛОВ
select AVG((PropED.Znach-BezUglov_test.Znach)/BezUglov_test.Znach)*100 --, PropED.Znach
from BezUglov_test, PropED
where BezUglov_test.Stroka=PropED.Stroka and BezUglov_test.Parametr=PropED.Parametr 

-- Посмотреть значения настоящие и восстановленные
select PropMN.Znach,BezUglov_test.Znach, (PropMN.Znach-BezUglov_test.Znach)/(BezUglov_test.Znach)*100, PropMN.Parametr 
from BezUglov_test, PropMN
where BezUglov_test.Stroka=PropMN.Stroka and BezUglov_test.Parametr=PropMN.Parametr and (PropMN.Znach-BezUglov_test.Znach)/(BezUglov_test.Znach)*100>100


select *
from BezUglov_test
where BezUglov_test.Znach is null
