#
# Divid D Editörü Makefile Dosyası
#
# Compiler : Digital Mars D (v2.058)
#
# -L/SUBSYSTEM:WINDOWS - Konsol ekranını gizle

all : divid.exe

divid.exe : temizle divid.obj editor.obj SayfaBaslik.obj
	dmd -w -wi -of"divid" divid.obj editor.obj SayfaBaslik.obj -L+C:\DLang\gtkD\src\build\GtkD.lib
	

SayfaBaslik.obj : SayfaBaslik.d
	dmd -c SayfaBaslik.d -IC:\DLang\gtkD\src -IC:\DLang\gtkD\srcsv
	
Editor.obj : Editor.d
	dmd -c Editor.d -IC:\DLang\gtkD\src -IC:\DLang\gtkD\srcsv

Divid.obj : Divid.d
	dmd -c Divid.d -IC:\DLang\gtkD\src -IC:\DLang\gtkD\srcsv

temizle :
	del Divid.obj
	del Editor.obj
	del SayfaBaslik.obj
	del Divid.exe
	@echo ------------------------
	