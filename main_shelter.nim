import os  # папки, файлы, аргументы командной строки
import sequtils, strutils, strformat  # работа со строками
import random  # для генерации случайных чисел
import streams

randomize()  # Для рандомизации генератора

type
 Post = enum
    NONE, Директор, Секретарь, Бухгалтер

var sqfemale_names : seq[string]
var sqmale_names : seq[string]
var sqlast_names : seq[string]
var sqpet_names : seq[string]

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
  var s : string  
  let nmType=rand(d)  
  if (nmType==cmale):  
    s=sqmale_names[rand(0..sqmale_names.len-1)]
  else:                                    
    s=sqfemale_names[rand(0..sqfemale_names.len-1)]
  s=s & " " & sqlast_names[rand(0..sqlast_names.len-1)]
  result=s
    
proc genRandDigit(nParam : string
  ): string =
  ## Возвращает целое число в заданном интервале
  ## price number totalCash discount,count
  var i : int
  case nParam
  of "uid" :
    i=rand(1..20)
    result= $i
  of "age" :
    i=rand(1..20)
    result= $i
  
proc genRandDate(
    d28: HSlice = 1..28,
    d30: HSlice = 1..30,    
    d31: HSlice = 1..31,    
    m: HSlice = 1..12,
    ybirthDate: HSlice = 1950..2005  
  ): string =  
  var vm, vd, vy : int
  vm=rand(m)
  case vm 
  of 1,3,5,7,8,10,12 : vd=rand(d31)   
  of 4,6,9,11 : vd=rand(d30)
  of 2 : vd=rand(d28)
  else :
    vd=0        
  vy=rand(ybirthDate)    
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
  with(csv, csvFileName, fmWrite):
    csv.writeLine(header) 
    for row in rows:
        csv.writeLine(row.toCsvRow)

proc genStaff(csvFileName: string, rowsCount: int) =  
  let header = "name,birthDate,uid" 
  var dataItem : seq[string]
  var data     : seq[seq[string]]

  for i in 1..rowsCount:
    dataItem.add(@[genRandName(), genRandDate(), genRandDigit("uid")])
    data.add(dataItem)
    dataItem = @[]
  genCSV(header,data,csvFileName)       

proc genManager(csvFileName: string, rowsCount: int) =  
  let header = "name,post" 
  var dataItem : seq[string]
  var data     : seq[seq[string]]

  dataItem.add(@[genRandName(), $Директор ])
  data.add(dataItem)
  dataItem = @[]
  dataItem.add(@[genRandName(), $Секретарь ])
  data.add(dataItem)
  dataItem = @[]
  dataItem.add(@[genRandName(), $Бухгалтер ])
  data.add(dataItem)
  dataItem = @[]      
  
  genCSV(header,data,csvFileName)         

proc genPet(csvFileName: string, rowsCount: int) =              
  let header = "name,age" 
  var dataItem : seq[string]
  var data     : seq[seq[string]]

  for i in 1..rowsCount:
    dataItem.add(@[genRandName(), genRandDigit("age")])
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
  sqpet_names = getData( getAppDir() / "src" / "pet_names.txt")

  genStaff(  
    getAppDir() / "data" / "shelter_staff.csv",
    rowsCount
  )
  genManager(  
    getAppDir() / "data" / "shelter_manager.csv",
    rowsCount 
  )
  genPet( 
    getAppDir() / "data" / "shelter_pet.csv",
    rowsCount*50
  )
           