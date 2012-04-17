#
# Divid D Editörü Makefile Dosyası
#
# Compiler : Digital Mars D (v2.058)
#

all : divid.exe


divid.exe : temizle divid.obj editor.obj
	dmd -w -wi -of"divid" divid.obj editor.obj -L+C:\DLang\dmd2\windows\lib\GtkD.lib

editor.obj : editor.d
	dmd -c editor.d

divid.obj : divid.d
	dmd -c divid.d

temizle :
	del divid.obj
	del editor.obj
	del divid.exe
	@echo .