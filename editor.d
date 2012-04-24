module Editor;

import std.stdio;
import std.file;
import std.conv;
import std.string;

import gtk.MainWindow, gtk.Main, gtk.Button, gtk.Label, gtk.VBox, gtk.HBox, gtk.Widget, gtk.ScrolledWindow, gtk.Notebook, gtk.Frame;
import gtk.Image, gtk.RcStyle, gtk.Box, gtk.ToolButton, gtk.MenuBar, gtk.Menu, gtk.MenuItem, gtk.FileChooserDialog, gtk.TextBuffer;
import gtk.AboutDialog, gtk.MessageDialog, gtk.TextIter, gtk.FileFilter, gtk.Statusbar;

import gsv.SourceView, gsv.SourceBuffer, gsv.SourceLanguage, gsv.SourceLanguageManager, gsv.SourceBuffer;
import gsv.SourceStyleSchemeManager, gsv.SourceStyleScheme, gsv.SourceGutter, gtk.CellRendererText;;

import gdk.Keysyms;

import gtkc.gdktypes;

import SayfaBaslik;

class Editor : MainWindow
{
	private Notebook defter;
	private Statusbar durumCubugu;

	public this()
	{
		super("Divid Metin Editörü (Geliştiriciler için) -- 0.5.3 (Begonya) [BETA]");
		this.setIconFromFile("resim\\tab_kapat2.png");
		//this.resize(300, 300);
		//this.move(20, 20);

		EkraniHazirla();
		setSizeRequest(640, 480);
		showAll();

		//setBorderWidth(10);
		//setPosition(GtkWindowPosition.POS_CENTER_ALWAYS);
	}

	private void EkraniHazirla()
	{
		defter = new Notebook();
		defter.addOnSwitchPage(&OnSekmeDegisti);
		defter.setTabPos(PositionType.TOP);
		//sekme.setBorderWidth(10);

		durumCubugu = new Statusbar();
		durumCubugu.push(1, "First message");

		VBox vboxAnaTablo = new VBox(false, 0);
    	vboxAnaTablo.packStart(AnaMenuHazirla, false, false, 0);
    	vboxAnaTablo.packStart(defter, true, true, 0);
    	vboxAnaTablo.packStart(durumCubugu, false, false, 0);
    	add(vboxAnaTablo);

    	/*	
		Widget sayfa = MetinEditoruHazirla("editor.d");
		defter.appendPage(sayfa, new SayfaBaslik("editor.d", defter, sayfa));

		Widget sayfa1 = MetinEditoruHazirla("sekme.d");
		defter.appendPage(sayfa1, new SayfaBaslik("sekme.d", defter, sayfa1)); 

		Widget sayfa2 = MetinEditoruHazirla("sekme.d");
		defter.appendPage(sayfa2, new SayfaBaslik("BaskaTest", defter, sayfa2));
		*/
	}

	private bool keyPerssed(GdkEventKey* e, Widget w)
	{
		int sayfaNo = defter.getCurrentPage();
		ScrolledWindow text = cast(ScrolledWindow)defter.getNthPage(sayfaNo);
		SourceView kaynak = cast(SourceView)text.getChild();
    	TextIter iter = new TextIter();
		kaynak.getBuffer().getIterAtMark(iter, kaynak.getBuffer().getInsert());

		string konumBilgi = format("Satir : %s, Sutun : %s", iter.getLine(), iter.getLineIndex());


    	if (e.state == ModifierType.CONTROL_MASK && e.keyval ==  GdkKeysyms.GDK_s)
    	{
    		MenuDosyaKaydet();

		    writeln("kaydedildi...");
		    konumBilgi = konumBilgi ~ ";Dosya kaydedildi...";
		    durumCubugu.push(2, konumBilgi);
        	return true;
    	}

		writefln(konumBilgi);

		durumCubugu.push(2, konumBilgi);

    	return false;
		/*
    	switch(event.keyval){
                case(GdkKeysyms.GDK_Up):    // up arrow
                    Stdout("up").nl;
                    break;
                case(GdkKeysyms.GDK_Down): // down arrow
                    Stdout("down").nl;
                    break;
                case(GdkKeysyms.GDK_Right): // right arrow
                    Stdout("right").nl;
                    break;
                case(GdkKeysyms.GDK_Left):  // left arrow
                    Stdout("left").nl;
                    break;
                default:
                    Stdout("default").nl;
                    break;
            }
            return false; 
            */
	}

	
	private Widget MetinEditoruHazirla(string dosyaAdi)
	{
	    SourceView metinEditoru = new SourceView();
		metinEditoru.addOnKeyPress(&keyPerssed); 

	    metinEditoru.setShowLineNumbers(true);
	    metinEditoru.setInsertSpacesInsteadOfTabs(true);
	    metinEditoru.setTabWidth(4);
	    metinEditoru.setHighlightCurrentLine(true);
		metinEditoru.modifyFont("Consolas", 10);
		metinEditoru.setLeftMargin(10);

	    SourceBuffer sb = metinEditoru.getBuffer();
	    sb.addOnChanged(&OnMetinDegisti);
	    
	    if (dosyaAdi != "bos")
	    	sb.setText(cast(string)std.file.read(dosyaAdi));

	    assert(sb !is null, "-> sb null");

	    ScrolledWindow scWindow = new ScrolledWindow();
	    scWindow.setPolicy(GtkPolicyType.AUTOMATIC, GtkPolicyType.AUTOMATIC);
	    scWindow.setShadowType(GtkShadowType.ETCHED_OUT);
	    scWindow.add(metinEditoru);
	   
	    SourceLanguageManager slm = new SourceLanguageManager();
	    SourceLanguage dLang = slm.getLanguage("d");

		SourceStyleSchemeManager sssm = new SourceStyleSchemeManager();
	    string[] styleSearchPaths = ["sablon\\styles"];
	    sssm.setSearchPath(styleSearchPaths);

	    SourceStyleScheme sema = sssm.getScheme("oblivion");
	    sb.setStyleScheme(sema);

		//writeln("test");
		//metinEditoru.getGutter(GtkTextWindowType.RIGHT);
		//SourceGutter gutter = metinEditoru.getGutter(GtkTextWindowType.LEFT);

		//CellRendererText render = new CellRendererText(); 
		//gutter.insert(render, 20);

	    if (dLang !is null)
	    {
	        writefln("Setting language to D");
	        sb.setLanguage(dLang);
	        sb.setHighlightSyntax(true);
	    }

	    //sourceView.modifyFont("Courier", 9);
	    //metinEditoru.setRightMarginPosition(72);
	    //metinEditoru.setShowRightMargin(true);
	    metinEditoru.setAutoIndent(true);

	    return scWindow;
	}

	private MenuBar AnaMenuHazirla()
	{
		MenuBar menuBar = new MenuBar();

		Menu menu = menuBar.append("_Dosya");;
		menu.append(new MenuItem(&OnMenuKomutuCalistir, "Yeni", "dosya.yeni"));
		menu.append(new MenuItem(&OnMenuKomutuCalistir, "Aç", "dosya.ac"));
		menu.append(new MenuItem(&OnMenuKomutuCalistir, "Kaydet", "dosya.kaydet"));
		menu.append(new MenuItem(&OnMenuKomutuCalistir, "Farklı Kaydet", "dosya.farkliKaydet"));
		menu.append(new MenuItem(&OnMenuKomutuCalistir, "Çıkış", "dosya.cikis"));

		menu = menuBar.append("_Düzen");
		menu.append(new MenuItem(&OnMenuKomutuCalistir,"_Find","edit.find"));
		menu.append(new MenuItem(&OnMenuKomutuCalistir,"_Search","edit.search"));

		menu = menuBar.append("_Yardım");
		menu.append(new MenuItem(&OnMenuKomutuCalistir,"Yardım","yardim.yardim"));
		menu.append(new MenuItem(&OnMenuKomutuCalistir,"Divid Hakkında","yardim.hakkinda"));

		return menuBar;
	}



	/*======================================================= MENU KOMUT METOTLARI BASI =============================*/
	
	private void MenuDosyaYeni()
	{
		Widget sayfa = MetinEditoruHazirla("bos");
		defter.appendPage(sayfa, new SayfaBaslik("Adsız", defter, sayfa));
		defter.showAll();
	}

	private void MenuDosyaAc()
	{
        string[] a = ["Aç", "İptal"];
		ResponseType[] r = [ResponseType.GTK_RESPONSE_OK, ResponseType.GTK_RESPONSE_CANCEL];
      	FileChooserDialog fcd = new FileChooserDialog("File Chooser", this, FileChooserAction.OPEN, a, r);
		
		FileFilter filtreTum = new FileFilter();
		filtreTum.setName("Tüm Dosyalar (*.*)");
		filtreTum.addPattern("*.*");

      	FileFilter filtreD = new FileFilter();
		filtreD.setName("D (*.d, *.di)");
		filtreD.addPattern("*.d");
		filtreD.addPattern("*.di");
		filtreD.addPattern("*.txt");
		
		fcd.addFilter(filtreTum);
		fcd.addFilter(filtreD);

		fcd.move(50, 50);

      	if (fcd.run() == ResponseType.GTK_RESPONSE_OK)
      	{
      		string dosyaAdresi = fcd.getFilename();
      		Widget sayfa = MetinEditoruHazirla(dosyaAdresi);
      		int gecerliSekmeNo = defter.appendPage(sayfa, new SayfaBaslik(dosyaAdresi, defter, sayfa));
      		defter.showAll();
      		defter.setCurrentPage(gecerliSekmeNo);
      	}
      	fcd.hide();
	}
	
	private void MenuDosyaKaydet()
	{
		int sayfaNo = defter.getCurrentPage();
      	Widget sayfa = defter.getNthPage(sayfaNo);
		SayfaBaslik baslik = cast(SayfaBaslik)defter.getTabLabel(sayfa);

		ScrolledWindow disPencere = cast(ScrolledWindow)defter.getNthPage(sayfaNo);
		SourceView editor = cast(SourceView)disPencere.getChild();

		if (baslik.VerDosyaAdi != "Adsız")
		{
			File dosya = File(baslik.VerDosyaAdresi, "wb");
		    dosya.write(editor.getBuffer().getText());

	    	writefln("-> K ->Kaydedildi... %s", baslik.VerDosyaAdresi);
		}
		else
		{
			MenuDosyaFarkliKaydet();
		}

	}

	private void MenuDosyaFarkliKaydet()
	{
        string[] a = ["Kaydet", "İptal"];
	    ResponseType[] r = [ResponseType.GTK_RESPONSE_OK, ResponseType.GTK_RESPONSE_CANCEL];
      	FileChooserDialog fcd = new FileChooserDialog("File Chooser", this, FileChooserAction.SAVE, a, r);

      	if (fcd.run() == ResponseType.GTK_RESPONSE_OK)
      	{
      		int sayfaNo = defter.getCurrentPage();
      		Widget sayfa = defter.getNthPage(sayfaNo);
      		SayfaBaslik baslik = cast(SayfaBaslik)defter.getTabLabel(sayfa);

      		ScrolledWindow disPencere = cast(ScrolledWindow)defter.getNthPage(sayfaNo);
      		SourceView editor = cast(SourceView)disPencere.getChild();

      		File dosya = File(fcd.getFilename(), "wb");
	        dosya.write(editor.getBuffer().getText());

	        baslik.YapDosyaAdresi(fcd.getFilename());

	        writefln("-> FK -> Kaydedildi... %s", baslik.VerDosyaAdresi);
      	}

      	fcd.hide();  
	}

	private void MenuYardimHakkinda()
	{
		string mesaj = "Divid Metin Editörü\n\n"
					   "D dilinde gtkD kütüphanesi kullanarak geliştirilmektedir.\n"
					   "Daha fazla bilgi için lütfen http://www.ddili.org adresini ziyaret edin.\n\n"
					   "Zafer Çelenk (http://www.zafercelenk.net)\n";

		MessageDialog d = new MessageDialog(this, GtkDialogFlags.MODAL, MessageType.INFO, ButtonsType.OK, mesaj);
		d.run();
		d.destroy();
	}
	
	private void MenuDosyaCikis()
	{
		Main.quit;
	}

	/*======================================================= MENU KOMUT METOTLARI SONU =============================*/	
		

	/*======================================================= OLAY METODLARI BASI =============================*/

	void OnMenuKomutuCalistir(MenuItem menuItem)
	{
		string action = menuItem.getActionName();
		switch( action )
		{
			case "dosya.yeni":
			    MenuDosyaYeni();
				break;

			case "dosya.ac":
				MenuDosyaAc();
		      	break;

		    case "dosya.kaydet":
                MenuDosyaKaydet();
		      	break;

			case "dosya.farkliKaydet":
                MenuDosyaFarkliKaydet();
		      	break;

			case "dosya.cikis":
                MenuDosyaCikis();
		      	break;

			case "yardim.hakkinda":
				MenuYardimHakkinda();
				break;

			default:
				MessageDialog d = new MessageDialog(
					this, 
					GtkDialogFlags.MODAL,
					MessageType.INFO,
					ButtonsType.OK,
					"You pressed menu item "~action);
				d.run();
				d.destroy();
			break;
		}
	}

	void OnSekmeDegisti(void *sekme, uint sekmeNo, Notebook defter)
	{

		int sayfaNo = defter.getCurrentPage();
		ScrolledWindow text = cast(ScrolledWindow)defter.getNthPage(sayfaNo);
		SourceView kaynak = cast(SourceView)text.getChild();
		SourceBuffer sb = kaynak.getBuffer();

		//writefln("Notebook switch to page %s, %s", sekmeNo, sb.getModified());

		// fullCollect helps finding objects that shouldn't have been collected\r
		//std.gc.fullCollect();

		//MessageDialog d = new MessageDialog(this, GtkDialogFlags.MODAL, MessageType.INFO, ButtonsType.OK, "You pressed menu item ");
		//d.run();
		//d.destroy();
	}

	void onWitgetActivate(Widget widget)
	{
		//
	}

	void OnMetinDegisti(TextBuffer textBuffer)
	{
		/*
		TextIter iter = new TextIter();
		textBuffer.getIterAtMark(iter, textBuffer.getInsert());
		int lineNumber = iter.getLine(); 
		*/

		TextIter iter = new TextIter();
		textBuffer.getIterAtMark(iter, textBuffer.getInsert());

		writefln("-> Satir : %s,   Sutun : %s", iter.getLine(), iter.getLineIndex());
	}
	/*======================================================= OLAY METODLARI SONU =============================*/	
}