Самодостаточный и простой вариант: `Д.МММ.ГГГГ-Д.МММ.ГГГГ`

* каждый день периода в едином формате

```sql
declare @weekdiff int; set @weekdiff = 0; -- /!\ - работать здесь :-)

declare @someday date; set @someday = dateadd(week, @weekdiff, current_timestamp);
declare @monday date; set @monday = datetrunc(iso_week, @someday);
declare @sunday date; set @sunday = dateadd(day, 6, @monday);

select datepart(iso_week, @someday) as "Неделя"
, concat(
    format(@monday, 'd.MMM.yyyy', 'ru-RU')
    , '-'
    , format(@sunday, 'd.MMM.yyyy', 'ru-RU')
) as "Период";
```

Вариант поизвращеннее: `Д.МММ[.ГГГГ]-Д.МММ.ГГГГ`

* если даты в одном году, первая дата усекается до месяца (год не выводится)
* иначе - первая дата выводится полностью

```sql
declare @weekdiff int; set @weekdiff = 0; -- /!\ - работать здесь :-)

declare @someday date; set @someday = dateadd(week, @weekdiff, current_timestamp);
declare @monday date; set @monday = datetrunc(iso_week, @someday);
declare @sunday date; set @sunday = dateadd(day, 6, @monday);

select datepart(iso_week, @someday) as "Неделя"
, concat(
    format(@monday, iif(datepart(year, @monday) = datepart(year, @sunday), 'd.MMM', 'd.MMM.yyyy'), 'ru-RU')
    , '-'
    , format(@sunday, 'd.MMM.yyyy', 'ru-RU')
    , iif(@someday = cast(current_timestamp as date), N' (Текущая неделя)', '')
) as "Период";
```

Полный изврат: `Д[.МММ[.ГГГГ]]-Д.МММ.ГГГГ`

* если неделя в одном месяце, первая дата усекается до дня
* если неделя в одном году, первая дата усекается до месяца
* иначе - обе даты выводятся в полном формате

Два варианта реализации: `CASE` или `IIF` (закомментирован)

```sql
declare @weekdiff int; set @weekdiff = 0; -- /!\ - работать здесь :-)

declare @someday date; set @someday = dateadd(week, @weekdiff, current_timestamp);
declare @monday date; set @monday = datetrunc(iso_week, @someday);
declare @sunday date; set @sunday = dateadd(day, 6, @monday);

select datepart(iso_week, @someday) as "Неделя"
, concat(
    case
    when datepart(month, @monday) = datepart(month, @sunday) then cast(datepart(day, @monday) as varchar)
    when datepart(year, @monday) = datepart(year, @sunday) then format(@monday, 'd.MMM', 'ru-RU')
    else format(@monday, 'd.MMM.yyyy', 'ru-RU')
    end
--    iif(
--      datepart(month, @monday) = datepart(month, @sunday)
--      , cast(datepart(day, @monday) as varchar)
--      , format(@monday, iif(datepart(year, @monday) = datepart(year, @sunday), 'd.MMM', 'd.MMM.yyyy'), 'ru-RU'))
    , '-'
    , format(@sunday, 'd.MMM.yyyy', 'ru-RU')
) as "Период";
```
