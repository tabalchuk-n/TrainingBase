///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Добавляет в справочник валют валюты из классификатора.
// При отсутствии обработки ЗагрузкаКурсовВалют валюты добавляются с наименованием "Валюта",
// символьный код соответствует цифровому.
//
// Параметры:
//   Коды - Массив - цифровые коды добавляемых валют.
//
// Возвращаемое значение:
//   Массив, СправочникСсылка.Валюты - ссылки созданных валют.
//
Функция ДобавитьВалютыПоКоду(Знач Коды) Экспорт
	
	Результат = Новый Массив();
	Если Метаданные.Обработки.Найти("ЗагрузкаКурсовВалют") <> Неопределено Тогда
		Результат = Обработки["ЗагрузкаКурсовВалют"].ДобавитьВалютыПоКоду(Коды);
	Иначе
		Для Каждого Код Из Коды Цикл
			ВалютаСсылка = Справочники.Валюты.НайтиПоКоду(Код);
			Если ВалютаСсылка.Пустая() Тогда
				ВалютаОбъект = Справочники.Валюты.СоздатьЭлемент();
				ВалютаОбъект.Код = Код;
				ВалютаОбъект.Наименование = Код;
				ВалютаОбъект.НаименованиеПолное = НСтр("ru = 'Валюта'");
				ВалютаОбъект.СпособУстановкиКурса = Перечисления.СпособыУстановкиКурсаВалюты.РучнойВвод;
				ВалютаОбъект.Записать();
				ВалютаСсылка = ВалютаОбъект.Ссылка;
			КонецЕсли;
			Результат.Добавить(ВалютаСсылка);
		КонецЦикла;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// Возвращает курс валюты на дату.
//
// Параметры:
//   Валюта    - СправочникСсылка.Валюты - валюта, для которой получается курс.
//   ДатаКурса - Дата - дата, на которую получается курс.
//
// Возвращаемое значение: 
//   Структура:
//    * Курс      - Число - курс валюты на указанную дату.
//    * Кратность - Число - кратность валюты на указанную дату.
//    * Валюта    - СправочникСсылка.Валюты - ссылка валюты.
//    * ДатаКурса - Дата - дата получения курса.
//
Функция ПолучитьКурсВалюты(Валюта, ДатаКурса) Экспорт
	
	Результат = РегистрыСведений.КурсыВалют.ПолучитьПоследнее(ДатаКурса, Новый Структура("Валюта", Валюта));
	
	Результат.Вставить("Валюта",    Валюта);
	Результат.Вставить("ДатаКурса", ДатаКурса);
	
	Возврат Результат;
	
КонецФункции

// Формирует представление суммы прописью в указанной валюте.
//
// Параметры:
//   СуммаЧислом - Число - сумма, которую надо представить прописью.
//   Валюта - СправочникСсылка.Валюты - валюта, в которой нужно представить сумму.
//   БезДробнойЧасти - Булево - указать Истина, если требуется получить сумму без дробной части (без копеек).
//   КодЯзыка - Строка - язык, на котором требуется получить сумму прописью.
//                       Состоит из кода языка по ISO 639-1 и, опционально, кода страны по ISO 3166-1, разделенных
//                       символом подчеркивания. Примеры: "en", "en_US", "en_GB", "ru", "ru_RU".
//                       Значение по умолчанию - язык конфигурации.
//
// Возвращаемое значение:
//   Строка - сумма прописью.
//
Функция СформироватьСуммуПрописью(СуммаЧислом, Валюта, БезДробнойЧасти = Ложь, Знач КодЯзыка = Неопределено) Экспорт
	
	Если Метаданные.Обработки.Найти("ЗагрузкаКурсовВалют") <> Неопределено Тогда
		Результат = Обработки["ЗагрузкаКурсовВалют"].СформироватьСуммуПрописью(СуммаЧислом, Валюта, БезДробнойЧасти, КодЯзыка);
	Иначе
		Результат = "";
	КонецЕсли;
	Возврат Результат;
	
КонецФункции

// Пересчитывает сумму из одной валюты в другую.
//
// Параметры:
//  Сумма          - Число - сумма, которую необходимо пересчитать;
//  ИсходнаяВалюта - СправочникСсылка.Валюты - пересчитываемая валюта;
//  НоваяВалюта    - СправочникСсылка.Валюты - валюта, в которую необходимо пересчитать;
//  Дата           - Дата - дата курсов валют.
//
// Возвращаемое значение:
//  Число - пересчитанная сумма.
//
Функция ПересчитатьВВалюту(Сумма, ИсходнаяВалюта, НоваяВалюта, Дата) Экспорт
	
	Возврат РаботаСКурсамиВалютКлиентСервер.ПересчитатьПоКурсу(Сумма,
		ПолучитьКурсВалюты(ИсходнаяВалюта, Дата),
		ПолучитьКурсВалюты(НоваяВалюта, Дата));
		
КонецФункции

// Предназначена для использования в конструкторе типа Число для денежных полей.
//
// Параметры:
//  ДопустимыйЗнакПоля - ДопустимыйЗнак - определяет допустимый знак числа. Значение по умолчанию - ДопустимыйЗнак.Любой.
// 
// Возвращаемое значение:
//  ОписаниеТипов - тип значения для денежного поля.
//
Функция ОписаниеТипаДенежногоПоля(Знач ДопустимыйЗнакПоля = Неопределено) Экспорт
	
	Если ДопустимыйЗнакПоля = Неопределено Тогда
		ДопустимыйЗнакПоля = ДопустимыйЗнак.Любой;
	КонецЕсли;
	
	Если ДопустимыйЗнакПоля = ДопустимыйЗнак.Любой Тогда
		Возврат Метаданные.ОпределяемыеТипы.ДенежнаяСуммаЛюбогоЗнака.Тип;
	КонецЕсли;
	
	Возврат Метаданные.ОпределяемыеТипы.ДенежнаяСуммаНеотрицательная.Тип;
	
КонецФункции

// Добавляет возможность вывода числового реквизита прописью при печати.
// Для вызова из УправлениеПечатьюПереопределяемый.ПриОпределенииИсточниковДанныхПечати.
// 
// Параметры:
//  ИсточникиДанныхПечати - см. УправлениеПечатьюПереопределяемый.ПриОпределенииИсточниковДанныхПечати.ИсточникиДанныхПечати
//
Процедура ПодключитьИсточникДанныхПечатиЧислоПрописью(ИсточникиДанныхПечати) Экспорт
	
	ИсточникиДанныхПечати.Добавить(СхемаДанныеПечатиСуммаПрописью(), "ДанныеПечатиСуммаПрописью");	
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий подсистем конфигурации.

// Параметры:
//   ТекущиеДела - см. ТекущиеДелаСервер.ТекущиеДела.
//
Процедура ПриЗаполненииСпискаТекущихДел(ТекущиеДела) Экспорт
	
	ОбъектМетаданных = Метаданные.Обработки.Найти("ЗагрузкаКурсовВалют");
	Если ОбъектМетаданных = Неопределено Тогда
		Возврат;
	КонецЕсли;

	МодульТекущиеДелаСервер = ОбщегоНазначения.ОбщийМодуль("ТекущиеДелаСервер");
	Если ОбщегоНазначения.РазделениеВключено() // В модели сервиса обновляется автоматически.
		Или ОбщегоНазначения.ЭтоАвтономноеРабочееМесто()
		Или Не ПравоДоступа("Изменение", Метаданные.РегистрыСведений.КурсыВалют)
		Или МодульТекущиеДелаСервер.ДелоОтключено("КлассификаторВалют") Тогда
		Возврат;
	КонецЕсли;
	
	КурсыАктуальны = КурсыАктуальны();
	
	// Процедура вызывается только при наличии подсистемы "Текущие дела", поэтому здесь
	// не делается проверка существования подсистемы.
	Разделы = МодульТекущиеДелаСервер.РазделыДляОбъекта(ОбъектМетаданных.ПолноеИмя());
	
	Для Каждого Раздел Из Разделы Цикл
		
		ИдентификаторВалюты = "КлассификаторВалют" + СтрЗаменить(Раздел.ПолноеИмя(), ".", "");
		Дело = ТекущиеДела.Добавить();
		Дело.Идентификатор  = ИдентификаторВалюты;
		Дело.ЕстьДела       = Не КурсыАктуальны;
		Дело.Представление  = НСтр("ru = 'Курсы валют устарели'");
		Дело.Важное         = Истина;
		Дело.Форма          = "Обработка.ЗагрузкаКурсовВалют.Форма";
		Дело.ПараметрыФормы = Новый Структура("ОткрытиеИзСписка", Истина);
		Дело.Владелец       = Раздел;
		
	КонецЦикла;
	
КонецПроцедуры

// См. ЗагрузкаДанныхИзФайлаПереопределяемый.ПриОпределенииСправочниковДляЗагрузкиДанных.
Процедура ПриОпределенииСправочниковДляЗагрузкиДанных(ЗагружаемыеСправочники) Экспорт
	
	// Загрузка в классификатор валюты запрещена.
	СтрокаТаблицы = ЗагружаемыеСправочники.Найти(Метаданные.Справочники.Валюты.ПолноеИмя(), "ПолноеИмя");
	Если СтрокаТаблицы <> Неопределено Тогда 
		ЗагружаемыеСправочники.Удалить(СтрокаТаблицы);
	КонецЕсли;
	
КонецПроцедуры

// См. ГрупповоеИзменениеОбъектовПереопределяемый.ПриОпределенииОбъектовСРедактируемымиРеквизитами.
Процедура ПриОпределенииОбъектовСРедактируемымиРеквизитами(Объекты) Экспорт
	Объекты.Вставить(Метаданные.Справочники.Валюты.ПолноеИмя(), "РеквизитыРедактируемыеВГрупповойОбработке");
КонецПроцедуры

// См. РегламентныеЗаданияПереопределяемый.ПриОпределенииНастроекРегламентныхЗаданий.
Процедура ПриОпределенииНастроекРегламентныхЗаданий(Настройки) Экспорт
	Если Метаданные.Обработки.Найти("ЗагрузкаКурсовВалют") <> Неопределено Тогда
		Обработки["ЗагрузкаКурсовВалют"].ПриОпределенииНастроекРегламентныхЗаданий(Настройки);
	КонецЕсли;
КонецПроцедуры

// См. ПользователиПереопределяемый.ПриОпределенииНазначенияРолей.
Процедура ПриОпределенииНазначенияРолей(НазначениеРолей) Экспорт
	
	// СовместноДляПользователейИВнешнихПользователей.
	НазначениеРолей.СовместноДляПользователейИВнешнихПользователей.Добавить(
		Метаданные.Роли.ЧтениеКурсовВалют.Имя);
	
КонецПроцедуры

// См. ОбщегоНазначенияПереопределяемый.ПриДобавленииПараметровРаботыКлиентаПриЗапуске.
Процедура ПриДобавленииПараметровРаботыКлиентаПриЗапуске(Параметры) Экспорт
	
	Если ОбщегоНазначения.РазделениеВключено() Или ОбщегоНазначения.ЭтоАвтономноеРабочееМесто() Тогда
		КурсыОбновляютсяОтветственными = Ложь; // В модели сервиса обновляются автоматически.
	ИначеЕсли НЕ ПравоДоступа("Изменение", Метаданные.РегистрыСведений.КурсыВалют) Тогда
		КурсыОбновляютсяОтветственными = Ложь; // Пользователь не может обновлять курсы валют.
	Иначе
		КурсыОбновляютсяОтветственными = КурсыЗагружаютсяИзИнтернета(); // Есть валюты, для которых можно загружать курсы.
	КонецЕсли;
	
	ВключитьОповещение = Не ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ТекущиеДела");
	РаботаСКурсамиВалютПереопределяемый.ПриОпределенииНеобходимостиПоказаПредупрежденияОбУстаревшихКурсахВалют(ВключитьОповещение);
	
	Параметры.Вставить("Валюты", Новый ФиксированнаяСтруктура("КурсыОбновляютсяОтветственными", (КурсыОбновляютсяОтветственными И ВключитьОповещение)));
	
КонецПроцедуры

// См. ОбщегоНазначенияПереопределяемый.ПриДобавленииИсключенийПоискаСсылок.
Процедура ПриДобавленииИсключенийПоискаСсылок(ИсключенияПоискаСсылок) Экспорт
	
	ИсключенияПоискаСсылок.Добавить(Метаданные.РегистрыСведений.КурсыВалют.ПолноеИмя());
	
КонецПроцедуры

// См. РаботаВБезопасномРежимеПереопределяемый.ПриЗаполненииРазрешенийНаДоступКВнешнимРесурсам.
Процедура ПриЗаполненииРазрешенийНаДоступКВнешнимРесурсам(ЗапросыРазрешений) Экспорт
	
	Если ОбщегоНазначения.РазделениеВключено() Тогда
		Возврат;
	КонецЕсли;
	
	МодульРаботаВБезопасномРежиме = ОбщегоНазначения.ОбщийМодуль("РаботаВБезопасномРежиме");
	ЗапросыРазрешений.Добавить(
		МодульРаботаВБезопасномРежиме.ЗапросНаИспользованиеВнешнихРесурсов(Разрешения()));
	
КонецПроцедуры

// См. ОбновлениеИнформационнойБазыБСП.ПриДобавленииОбработчиковОбновления.
Процедура ПриДобавленииОбработчиковОбновления(Обработчики) Экспорт
	
	Если Метаданные.Обработки.Найти("ЗагрузкаКурсовВалют") <> Неопределено Тогда
		Обработки["ЗагрузкаКурсовВалют"].ПриДобавленииОбработчиковОбновления(Обработчики);
	КонецЕсли;
	
КонецПроцедуры

// См. ИнтернетПоддержкаПользователейПереопределяемый.ПриИзмененииДанныхАутентификацииИнтернетПоддержки.
Процедура ПриИзмененииДанныхАутентификацииИнтернетПоддержки(ДанныеПользователя) Экспорт
	
	Если Метаданные.Обработки.Найти("ЗагрузкаКурсовВалют") <> Неопределено Тогда
		Обработки["ЗагрузкаКурсовВалют"].ПриИзмененииДанныхАутентификацииИнтернетПоддержки(ДанныеПользователя);
	КонецЕсли;
	
КонецПроцедуры

// Проверяет наличие установленного курса и кратности валюты на 1 января 1980 года.
// В случае отсутствия устанавливает курс и кратность равными единице.
//
// Параметры:
//  Валюта - ссылка на элемент справочника Валют.
//
Процедура ПроверитьКорректностьКурсаНа01_01_1980(Валюта) Экспорт
	
	ДатаКурса = Дата("19800101");
	
	Блокировка = Новый БлокировкаДанных;
	ЭлементБлокировки = Блокировка.Добавить("РегистрСведений.КурсыВалют");
	ЭлементБлокировки.УстановитьЗначение("Валюта", Валюта);
	ЭлементБлокировки.УстановитьЗначение("Период", ДатаКурса);
	
	НачатьТранзакцию();
	Попытка
		Блокировка.Заблокировать();
		СтруктураКурса = РегистрыСведений.КурсыВалют.ПолучитьПоследнее(ДатаКурса, Новый Структура("Валюта", Валюта));
		
		Если (СтруктураКурса.Курс = 0) Или (СтруктураКурса.Кратность = 0) Тогда
			НаборЗаписей = РегистрыСведений.КурсыВалют.СоздатьНаборЗаписей();
			НаборЗаписей.Отбор.Валюта.Установить(Валюта);
			НаборЗаписей.Отбор.Период.Установить(ДатаКурса);
			Запись = НаборЗаписей.Добавить();
			Запись.Валюта = Валюта;
			Запись.Период = ДатаКурса;
			Запись.Курс = 1;
			Запись.Кратность = 1;
			НаборЗаписей.ДополнительныеСвойства.Вставить("ПропуститьПроверкуЗапретаИзменения");
			НаборЗаписей.Записать();
		КонецЕсли;
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

// См. УправлениеПечатьюПереопределяемый.ПриПодготовкеДанныхПечати
Процедура ПриПодготовкеДанныхПечати(ИсточникиДанных, ВнешниеНаборыДанных, ИдентификаторСхемыКомпоновкиДанных, КодЯзыка,
	ДополнительныеПараметры) Экспорт
	
	Если ИдентификаторСхемыКомпоновкиДанных = "ДанныеПечатиСуммаПрописью" Тогда
		ДополнительныеПараметры.ДанныеИсточниковСгруппированыПоВладельцуИсточникаДанных = Истина;
		ВнешниеНаборыДанных.Вставить("Данные", ДанныеПечатиСуммаПрописью(ДополнительныеПараметры.ОписанияИсточниковДанных, КодЯзыка));
		Возврат;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ЗагрузитьАктуальныйКурс(ПараметрыЗагрузки = Неопределено, АдресРезультата = Неопределено) Экспорт
	
	Если Метаданные.Обработки.Найти("ЗагрузкаКурсовВалют") <> Неопределено Тогда
		Обработки["ЗагрузкаКурсовВалют"].ЗагрузитьАктуальныйКурс(ПараметрыЗагрузки, АдресРезультата);
	КонецЕсли;
	
КонецПроцедуры

// Возвращает список разрешений для загрузки курсов валют из внешних ресурсов.
//
// Возвращаемое значение:
//  Массив
//
Функция Разрешения()
	
	Разрешения = Новый Массив;
	ИмяОбработки = "ЗагрузкаКурсовВалют";
	Если Метаданные.Обработки.Найти(ИмяОбработки) <> Неопределено Тогда
		Обработки[ИмяОбработки].ДобавитьРазрешения(Разрешения);
	КонецЕсли;
	
	Возврат Разрешения;
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Экспортные служебные процедуры и функции.

// Возвращает массив валют, курсы которых загружаются из внешних ресурсов.
//
Функция ЗагружаемыеВалюты() Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Валюты.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.Валюты КАК Валюты
	|ГДЕ
	|	Валюты.СпособУстановкиКурса = ЗНАЧЕНИЕ(Перечисление.СпособыУстановкиКурсаВалюты.ЗагрузкаИзИнтернета)
	|	И НЕ Валюты.ПометкаУдаления
	|
	|УПОРЯДОЧИТЬ ПО
	|	Валюты.НаименованиеПолное";

	Возврат Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Ссылка");
	
КонецФункции

Функция ЗаполнитьДанныеКурсаДляВалюты(ВыбраннаяВалюта) Экспорт
	
	ДанныеКурса = Новый Структура("ДатаКурса, Курс, Кратность");
	
	Запрос = Новый Запрос;
	
	Запрос.Текст = "ВЫБРАТЬ РегКурсы.Период, РегКурсы.Курс, РегКурсы.Кратность
	              | ИЗ РегистрСведений.КурсыВалют.СрезПоследних(&ОкончаниеПериодаЗагрузки, Валюта = &ВыбраннаяВалюта) КАК РегКурсы";
	Запрос.УстановитьПараметр("ВыбраннаяВалюта", ВыбраннаяВалюта);
	Запрос.УстановитьПараметр("ОкончаниеПериодаЗагрузки", ТекущаяДатаСеанса());
	
	ВыборкаКурс = Запрос.Выполнить().Выбрать();
	ВыборкаКурс.Следующий();
	
	ДанныеКурса.ДатаКурса = ВыборкаКурс.Период;
	ДанныеКурса.Курс      = ВыборкаКурс.Курс;
	ДанныеКурса.Кратность = ВыборкаКурс.Кратность;
	
	Возврат ДанныеКурса;
	
КонецФункции

Функция СписокЗависимыхВалют(ВалютаБазовая, ДополнительныеСвойства = Неопределено) Экспорт
	
	Кэшировать = (ТипЗнч(ДополнительныеСвойства) = Тип("Структура"));
	
	Если Кэшировать Тогда
		
		ЗависимыеВалюты = ДополнительныеСвойства.ЗависимыеВалюты.Получить(ВалютаБазовая);
		
		Если ТипЗнч(ЗависимыеВалюты) = Тип("ТаблицаЗначений") Тогда
			Возврат ЗависимыеВалюты;
		КонецЕсли;
		
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	СпрВалюты.Ссылка,
	|	СпрВалюты.Наценка,
	|	СпрВалюты.СпособУстановкиКурса,
	|	СпрВалюты.ФормулаРасчетаКурса
	|ИЗ
	|	Справочник.Валюты КАК СпрВалюты
	|ГДЕ
	|	СпрВалюты.ОсновнаяВалюта = &ВалютаБазовая
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	СпрВалюты.Ссылка,
	|	СпрВалюты.Наценка,
	|	СпрВалюты.СпособУстановкиКурса,
	|	СпрВалюты.ФормулаРасчетаКурса
	|ИЗ
	|	Справочник.Валюты КАК СпрВалюты
	|ГДЕ
	|	СпрВалюты.ФормулаРасчетаКурса ПОДОБНО &СимвольныйКод";
	
	Запрос.УстановитьПараметр("ВалютаБазовая", ВалютаБазовая);
	Запрос.УстановитьПараметр("СимвольныйКод", "%" + Строка(ВалютаБазовая) + "%");
	
	ЗависимыеВалюты = Запрос.Выполнить().Выгрузить();
	
	Если Кэшировать Тогда
		
		ДополнительныеСвойства.ЗависимыеВалюты.Вставить(ВалютаБазовая, ЗависимыеВалюты);
		
	КонецЕсли;
	
	Возврат ЗависимыеВалюты;
	
КонецФункции

Процедура ОбновитьКурсВалюты(Параметры, АдресРезультата) Экспорт
	
	ЗависимаяВалюта = Параметры.Валюта;
	СписокВалют = Параметры.Валюта.ИспользуемыеВалютыПриРасчетеКурса;
	
	ТекстЗапроса =
	"ВЫБРАТЬ
	|	КурсыВалют.Период КАК Период,
	|	КурсыВалют.Валюта КАК Валюта
	|ИЗ
	|	РегистрСведений.КурсыВалют КАК КурсыВалют
	|ГДЕ
	|	КурсыВалют.Валюта В(&Валюта)
	|
	|СГРУППИРОВАТЬ ПО
	|	КурсыВалют.Период,
	|	КурсыВалют.Валюта
	|
	|УПОРЯДОЧИТЬ ПО
	|	Период";
	
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("Валюта", СписокВалют);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	ОбновленныеПериоды = Новый Соответствие;
	Пока Выборка.Следующий() Цикл
		Если ОбновленныеПериоды[Выборка.Период] <> Неопределено Тогда 
			Продолжить;
		КонецЕсли;
		
		НачатьТранзакцию();
		Попытка
			Для Каждого Валюта Из СписокВалют Цикл
				Блокировка = Новый БлокировкаДанных;
				ЭлементБлокировки = Блокировка.Добавить("РегистрСведений.КурсыВалют");
				ЭлементБлокировки.УстановитьЗначение("Валюта", Валюта);
				ЭлементБлокировки.УстановитьЗначение("Период", Выборка.Период);
			КонецЦикла;
			Блокировка.Заблокировать();
			
			НаборЗаписей = РегистрыСведений.КурсыВалют.СоздатьНаборЗаписей();
			НаборЗаписей.Отбор.Валюта.Установить(Выборка.Валюта);
			НаборЗаписей.Отбор.Период.Установить(Выборка.Период);
			НаборЗаписей.Прочитать();
			НаборЗаписей.ДополнительныеСвойства.Вставить("ОбновитьКурсЗависимойВалюты", ЗависимаяВалюта);
			НаборЗаписей.ДополнительныеСвойства.Вставить("КодыВалют", Параметры.КодыВалют);
			НаборЗаписей.ДополнительныеСвойства.Вставить("ОбновленныеПериоды", ОбновленныеПериоды);
			НаборЗаписей.ДополнительныеСвойства.Вставить("ПропуститьПроверкуЗапретаИзменения");
			НаборЗаписей.Записать();
			
			ЗафиксироватьТранзакцию();
		Исключение
			ОтменитьТранзакцию();
			ВызватьИсключение;
		КонецПопытки;
		
		ОбновленныеПериоды.Вставить(Выборка.Период, Истина);
	КонецЦикла;
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обновление курсов валют

// Проверяет актуальность курсов всех валют.
//
Функция КурсыАктуальны() Экспорт
	ТекстЗапроса =
	"ВЫБРАТЬ
	|	Валюты.Ссылка КАК Ссылка
	|ПОМЕСТИТЬ втВалюты
	|ИЗ
	|	Справочник.Валюты КАК Валюты
	|ГДЕ
	|	Валюты.СпособУстановкиКурса = ЗНАЧЕНИЕ(Перечисление.СпособыУстановкиКурсаВалюты.ЗагрузкаИзИнтернета)
	|	И Валюты.ПометкаУдаления = ЛОЖЬ
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ ПЕРВЫЕ 1
	|	1 КАК Поле1
	|ИЗ
	|	втВалюты КАК Валюты
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.КурсыВалют КАК КурсыВалют
	|		ПО Валюты.Ссылка = КурсыВалют.Валюта
	|			И (КурсыВалют.Период = &ТекущаяДата)
	|ГДЕ
	|	КурсыВалют.Валюта ЕСТЬ NULL ";
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ТекущаяДата", НачалоДня(ТекущаяДатаСеанса()));
	Запрос.Текст = ТекстЗапроса;
	
	Возврат Запрос.Выполнить().Пустой();
КонецФункции

// Определяет есть ли хоть одна валюта, курс которой может загружаться из сети Интернет.
//
Функция КурсыЗагружаютсяИзИнтернета()
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	1 КАК Поле1
	|ИЗ
	|	Справочник.Валюты КАК Валюты
	|ГДЕ
	|	Валюты.СпособУстановкиКурса = ЗНАЧЕНИЕ(Перечисление.СпособыУстановкиКурсаВалюты.ЗагрузкаИзИнтернета)
	|	И Валюты.ПометкаУдаления = ЛОЖЬ";
	Возврат НЕ Запрос.Выполнить().Пустой();
КонецФункции

Функция СхемаДанныеПечатиСуммаПрописью()
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.Печать") Тогда
		МодульУправлениеПечатью = ОбщегоНазначения.ОбщийМодуль("УправлениеПечатью");
	
		СписокПолей = МодульУправлениеПечатью.ТаблицаПолейДанныхПечати();
		
		Поле = СписокПолей.Добавить();
		Поле.Идентификатор = "Ссылка";
		Поле.Представление = НСтр("ru = 'Ссылка'");
		Поле.ТипЗначения = Новый ОписаниеТипов();	
	
		Поле = СписокПолей.Добавить();
		Поле.Идентификатор = "ЧислоПрописью";
		Поле.Представление = НСтр("ru = 'Число прописью'");
		Поле.ТипЗначения = Новый ОписаниеТипов("Строка");
		
		Возврат МодульУправлениеПечатью.СхемаКомпоновкиДанныхПечати(СписокПолей);
	КонецЕсли;
	
КонецФункции

Функция ДанныеПечатиСуммаПрописью(ОписанияИсточниковДанных, КодЯзыка)
	
	ДанныеПечати = Новый ТаблицаЗначений();
	ДанныеПечати.Колонки.Добавить("Ссылка");
	ДанныеПечати.Колонки.Добавить("ЧислоПрописью");
	
	Для Каждого ОписаниеИсточника Из ОписанияИсточниковДанных Цикл
		СтрокаТаблицы = ДанныеПечати.Добавить();
		СтрокаТаблицы.Ссылка = ОписаниеИсточника.Владелец;
		СтрокаТаблицы.ЧислоПрописью = СформироватьСуммуПрописью(
			ОписаниеИсточника.Значение, ОписаниеИсточника.Владелец.ВалютаДокумента, , КодЯзыка);
	КонецЦикла;
	
	Возврат ДанныеПечати;
	
КонецФункции

#КонецОбласти
