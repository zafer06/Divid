#
# Divid D Editörü Makefile Dosyası
#
# Compiler : Digital Mars D (v2.058)
#

all : divid.exe

divid.exe : temizle divid.obj editor.obj SayfaBaslik.obj
	dmd -w -wi -of"divid" divid.obj editor.obj SayfaBaslik.obj -L+C:\DLang\dmd2\windows\lib\GtkD.lib
	

SayfaBaslik.obj : SayfaBaslik.d
	dmd -c SayfaBaslik.d -IC:\DLang\dmd2\src\gtkD\src -IC:\DLang\dmd2\src\gtkD\srcsv
	@echo .

Editor.obj : Editor.d
	dmd -c Editor.d -IC:\DLang\dmd2\src\gtkD\src -IC:\DLang\dmd2\src\gtkD\srcsv

Divid.obj : Divid.d
	dmd -c Divid.d -IC:\DLang\dmd2\src\gtkD\src -IC:\DLang\dmd2\src\gtkD\srcsv

temizle :
	del Divid.obj
	del Editor.obj
	del SayfaBaslik.obj
	del Divid.exe
	@echo .