///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ПерейтиКНастройкамНажатие(Элемент)
	Закрыть();
	ОткрытьФорму("Обработка.НастройкиЦентраМониторинга.Форма.НастройкиЦентраМониторинга");
КонецПроцедуры

&НаКлиенте
Процедура Да(Команда)
	НовыеПараметры = Новый Структура("ОтправлятьФайлыДампов", 1);
	УстановитьПараметрыЦентраМониторинга(НовыеПараметры);
	Закрыть();
КонецПроцедуры

&НаКлиенте
Процедура Нет(Команда)
	НовыеПараметры = Новый Структура("ОтправлятьФайлыДампов", 0);
	НовыеПараметры.Вставить("РезультатОтправки", НСтр("ru = 'Пользователь отказал в предоставлении полных дампов.'"));
	УстановитьПараметрыЦентраМониторинга(НовыеПараметры);
	Закрыть();
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервереБезКонтекста
Процедура УстановитьПараметрыЦентраМониторинга(НовыеПараметры)
	ЦентрМониторингаСлужебный.УстановитьПараметрыЦентраМониторингаВнешнийВызов(НовыеПараметры);
КонецПроцедуры

#КонецОбласти

