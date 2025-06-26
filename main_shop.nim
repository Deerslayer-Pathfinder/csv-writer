import os  # папки, файлы, аргументы командной строки
import sequtils, strutils, strformat  # работа со строками
import random  # для генерации случайных чисел
import streams

randomize()  # Для рандомизации генератора

type    
  Post = enum
    NONE, Директор, Кассир, Уборщик, Консультант, Менеджер 

var sqfemale_names : seq[string]
var sqmale_names : seq[string]
var sqlast_names : seq[string]
var sqgood_titles : seq[string]

proc getData(fileName: string): seq[string] =
  ## Получает все не пустные строки из файла
  let file = open(fileName)
  result = file.readAll.splitLines.filterIt(it != "")
  file.close()
                  
proc genRandName(        
    d: HSlice = 1..2        
  ): string =
  ## Возвращает Имя
  const cmale = 1  
  let nmType=rand(d)  
  if (nmType==cmale):  
    sqmale_names[rand(0..sqmale_names.len-1)]
  else:                                    
    sqfemale_names[rand(0..sqfemale_names.len-1)]
         
proc genRandLastName(
  ): string =
  ## Возвращает Фамилию  
  sqlast_names[rand(0..sqlast_names.len-1)]

proc genRandgood_titles(
  ): string =
  ## Возвращает Товар  
  sqgood_titles[rand(0..sqgood_titles.len-1)]  
  
proc genRandPost(
  ): Post =
  ## Возвращает Должности
  var iRand=rand(2..ord(high(Post)))
  
  case iRand  
  of 2 :    
    Кассир  
  of 3 :  
    Уборщик
  of 4 :    
    Консультант          
  of 5 : 
    Менеджер
  else :
    NONE      
    
proc genRandDigit(nParam : string
  ): string =
  ## Возвращает целое число в заданном интервале
  ## price number totalCash discount,count
  var f : float
  var i : int
  case nParam 
  of "price" :  
    f=rand(1..10000)/100
    result= fmt"{f:9.2f}".strip
  of "totalCash" :  
    f=rand(1..100000)/100
    result= fmt"{f:9.2f}".strip                    
  of "number" :
    i=rand(1..10)
    result= $i
  of "count" :
    i=rand(1..1000)
    result= $i
  of "discount" :
    f=rand(100..10000)/100
    result= fmt"{f:9.2f}".strip    

proc genRandBool(
  ): string =
  var i=rand(1..2)
  if i==1:
    "true"
  else:
    "false"  
  
proc genRandDate(
    nParam : string,
    d28: HSlice = 1..28,
    d30: HSlice = 1..30,    
    d31: HSlice = 1..31,    
    m: HSlice = 1..12,
    ybirthDate: HSlice = 1950..2005,
    yendDate: HSlice = 2025..2030    
  ): string =
  ## Возвращает строку даты на основе переданного диапазона значений
  ## По умолчанию, день: от 1 до 28
  ## месяц: от 1 до 12
  ## год: с 1970 по 2000
  ## Учтите, что для срока годности как минимум год должен быть другим.
  var vm, vd, vy : int
  vm=rand(m)
  case vm 
  of 1,3,5,7,8,10,12 : vd=rand(d31)   
  of 4,6,9,11 : vd=rand(d30)
  of 2 : vd=rand(d28)
  else :
    vd=0        
  if nParam=="birthDate":
    vy=rand(ybirthDate)
  else:
    vy=rand(yendDate)  
  fmt"{vd:02}.{vm:02}.{vy}"  
                   
proc toCsvRow(data: varargs[string, `$`]): string =
  data.mapIt("\"$1\"" % it).join(",")  
                
template with(streamVar, fName, mode, actions) =
  var streamVar: FileStream = newFileStream(fName, mode)
  try:
    actions
  finally:
    streamVar.close()  
  
proc genCSV(
    header: string = "",
    rows: seq[seq[string]] = @[@[""]],
    csvFileName: string = "default.csv"
  ) =
  ## Вносит заголовок и строки в csvFileName
  ## если значения не переданы, то должны использоваться значения по умолчанию  
  with(csv, csvFileName, fmWrite):
    csv.writeLine(header) 
    for row in rows:
        csv.writeLine(row.toCsvRow)

proc genStaff(csvFileName: string, rowsCount: int) =
  ## Функция генерации сотрудников
  ## 
  ## Для формирования CSV-заголовка используйте наименования атрибутов объекта Staff
  ## Для записи данных рекомендуется реализовать функцию genCSV и использовать
  ## её во всех трех генераторах  
  let header = "firstName,lastName,birthDate,post" 
  var dataItem : seq[string]
  var data     : seq[seq[string]]
            
  dataItem.add(@[genRandName(), genRandLastName() , genRandDate("birthDate"), $Директор])
  data.add(dataItem)
  dataItem = @[]  
  for i in 2..rowsCount:
    dataItem.add(@[genRandName(), genRandLastName() , genRandDate("birthDate"), $genRandPost()])
    data.add(dataItem)
    dataItem = @[]
  genCSV(header,data,csvFileName)       

proc genGoods(csvFileName: string, rowsCount: int) =
  ## Функция генерации товаров
  ## 
  ## Для формирования CSV-заголовка используйте наименования атрибутов объекта Good
  ## Для записи данных рекомендуется реализовать функцию genCSV и использовать
  ## её во всех трех генераторах
  let header = "title,price,endDate,discount,count" 
  var dataItem : seq[string]
  var data     : seq[seq[string]]

  for i in 1..rowsCount:
    dataItem.add(@[genRandgood_titles(), genRandDigit("price") , genRandDate("endDate"), genRandDigit("discount"), genRandDigit("count") ])
    data.add(dataItem)
    dataItem = @[]
  genCSV(header,data,csvFileName)         

proc genCashes(csvFileName: string, rowsCount: int) =
  ## Функция генерации касс
  ## 
  ## Для формирования CSV-заголовка используйте наименования атрибутов объекта Cash
  ## Для записи данных рекомендуется реализовать функцию genCSV и использовать
  ## её во всех трех генераторах            
  let header = "number,free,totalCash" 
  var dataItem : seq[string]
  var data     : seq[seq[string]]

  for i in 1..rowsCount:
    dataItem.add(@[ genRandDigit("number") , genRandBool(), genRandDigit("totalCash") ])
    data.add(dataItem)
    dataItem = @[]
  genCSV(header,data,csvFileName)         
  

when isMainModule:
  var rowsCount = 0  # Сколько строк писать
  if paramCount() > 0:  # Если передан аргумент командной строки
    rowsCount = paramStr(1).parseInt  # Присваиваем новое значение
  else:
    stderr.writeLine("Nothing to write. Quit")  # Ошибка
    quit()  # Завершаем работу
  
  #Подготавливаем исходные справочники
  sqfemale_names = getData( getAppDir() / "src" / "female_names.txt")
  sqmale_names = getData( getAppDir() / "src" / "male_names.txt")
  sqlast_names = getData( getAppDir() / "src" / "last_names.txt")
  sqgood_titles = getData( getAppDir() / "src" / "good_titles.txt")

  genStaff(  # Генерируем сотрудников
    getAppDir() / "data" / "shop_staff.csv",
    rowsCount
  )
  genGoods(  # Генерируем товары
    getAppDir() / "data" / "shop_goods.csv",
    rowsCount * 10  # в 10 раз больше
  )
  genCashes(  # Генерируем кассы
    getAppDir() / "data" / "shop_cashes.csv",
    rowsCount div 10  # в 10 раз меньше
  )
           