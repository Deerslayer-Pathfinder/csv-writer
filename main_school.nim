import os  # папки, файлы, аргументы командной строки
import sequtils, strutils  # работа со строками
import random  # для генерации случайных чисел
import streams

randomize()  # Для рандомизации генератора

var sqfemale_names : seq[string]
var sqmale_names : seq[string]
var sqlast_names : seq[string]

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
    
proc genRandDigit(): string =  
  var i : int
  i=rand(1..11)
  result= $i
 
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

proc genDirector(csvFileName: string, rowsCount: int) =  
  let header = "firstname,lastname" 
  var dataItem : seq[string]
  var data     : seq[seq[string]]
  
  dataItem.add(@[genRandName(), genRandLastName()])
  data.add(dataItem)  
  genCSV(header,data,csvFileName)       

proc genTeacher(csvFileName: string, rowsCount: int) =  
  let header = "firstname,lastname,class" 
  var dataItem : seq[string]
  var data     : seq[seq[string]]

  for i in 1..rowsCount:
    dataItem.add(@[genRandName(), genRandLastName(), genRandDigit()])
    data.add(dataItem)
    dataItem = @[]  
  genCSV(header,data,csvFileName)         

proc genStudent(csvFileName: string, rowsCount: int) =              
  let header = "firstname,lastname,class" 
  var dataItem : seq[string]
  var data     : seq[seq[string]]

  for i in 1..rowsCount:
    dataItem.add(@[genRandName(), genRandLastName(), genRandDigit()])
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
  
  genDirector(  
    getAppDir() / "data" / "school_Director.csv",
    rowsCount
  )
  genTeacher(  
    getAppDir() / "data" / "school_Teacher.csv",
    rowsCount 
  )
  genStudent( 
    getAppDir() / "data" / "school_Student.csv",
    rowsCount*10
  )
           