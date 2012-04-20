module editor;

import std.stdio;
import std.file;
import std.conv;
import std.string;

import gtk.MainWindow, gtk.Main, gtk.Button, gtk.Label, gtk.VBox, gtk.HBox, gtk.Widget, gtk.ScrolledWindow, gtk.Notebook, gtk.Frame;
import gtk.Image, gtk.RcStyle, gtk.Box, gtk.ToolButton, gtk.MenuBar, gtk.Menu, gtk.MenuItem, gtk.FileChooserDialog, gtk.TextBuffer;
import gtk.AboutDialog, gtk.MessageDialog, gtk.TextIter, gtk.FileFilter;

import gsv.SourceView, gsv.SourceBuffer, gsv.SourceLanguage, gsv.SourceLanguageManager, gsv.SourceBuffer;
import gsv.SourceStyleSchemeManager, gsv.SourceStyleScheme, gsv.SourceGutter, gtk.CellRendererText;;

import gdk.Keysyms;

import gtkc.gdktypes;


class Editor : MainWindow
{
	private Notebook defter;

	public this()
	{
		super("Divid Metin Editörü (Geliştiriciler için) -- 0.5.3 (Begonya) [BETA]");
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

		VBox vboxAnaTablo = new VBox(false, 0);
    	vboxAnaTablo.packStart(getMenuBar, false, false, 0);
    	vboxAnaTablo.packStart(defter, true, true, 2);
    	//vboxAnaTablo.packStart(sekme, true, true, 2);
    	add(vboxAnaTablo);

		Frame frame = new Frame("Kullanıcı Girişi");
		frame.setSizeRequest(100, 300);

		Label lblTabGirisBaslik = new Label("Kullanıcı Girişi");

		Widget sayfa = MetinEditoruHazirla("editor.d");
		defter.appendPage(sayfa, new SayfaBaslik("editor.d", defter, sayfa));

		Widget sayfa1 = MetinEditoruHazirla("sekme.d");
		defter.appendPage(sayfa1, new SayfaBaslik("sekme.d", defter, sayfa1)); 

		Widget sayfa2 = MetinEditoruHazirla("sekme.d");
		defter.appendPage(sayfa2, new SayfaBaslik("BaskaTest", defter, sayfa2));
	}

	bool keyPerssed(GdkEventKey* e, Widget w)
	{
    	if (e.state == ModifierType.CONTROL_MASK && e.keyval ==  GdkKeysyms.GDK_s)
    	{
        	int sayfaNo = defter.getCurrentPage();
        	Widget sayfa = defter.getNthPage(sayfaNo);
			SayfaBaslik baslik = cast(SayfaBaslik)defter.getTabLabel(sayfa);

			ScrolledWindow text = cast(ScrolledWindow)defter.getNthPage(sayfaNo);
		    SourceView kaynak = cast(SourceView)text.getChild();

			File dosya = File(baslik.DosyaAdresi, "wb");
			dosya.write(kaynak.getBuffer().getText());

		    writeln("kaydedildi...");
        	return true;
    	}

			int sayfaNo = defter.getCurrentPage();
			ScrolledWindow text = cast(ScrolledWindow)defter.getNthPage(sayfaNo);
		    SourceView kaynak = cast(SourceView)text.getChild();
    	TextIter iter = new TextIter();
		kaynak.getBuffer().getIterAtMark(iter, kaynak.getBuffer().getInsert());

		writefln("-> Satir : %s,   Sutun : %s", iter.getLine(), iter.getLineIndex());

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
        string[] styleSearchPaths = ["E:\\Proje - D\\Divid\\sablon\\styles"];
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

	MenuBar getMenuBar()
	{
		MenuBar menuBar = new MenuBar();

		Menu menu = menuBar.append("_File");;
		menu.append(new MenuItem(&OnMenuKomutuCalistir, "_New","file.new"));
		menu.append(new MenuItem(&OnMenuKomutuCalistir, "_Open","file.open"));
		menu.append(new MenuItem(&OnMenuKomutuCalistir, "_Save","file.save"));
		menu.append(new MenuItem(&OnMenuKomutuCalistir, "_Close","file.close"));
		menu.append(new MenuItem(&OnMenuKomutuCalistir, "E_xit","file.exit"));

		menu = menuBar.append("_Edit");
		menu.append(new MenuItem(&OnMenuKomutuCalistir,"_Find","edit.find"));
		menu.append(new MenuItem(&OnMenuKomutuCalistir,"_Search","edit.search"));

		menu = menuBar.append("_Help");
		menu.append(new MenuItem(&OnMenuKomutuCalistir,"_About","help.about"));

		return menuBar;
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

	void OnMenuKomutuCalistir(MenuItem menuItem)
	{
		string action = menuItem.getActionName();
		switch( action )
		{
			case "file.new":
				Widget sayfa = MetinEditoruHazirla("bos");
				defter.appendPage(sayfa, new SayfaBaslik("Adsiz", defter, sayfa));
				defter.showAll();
				break;

			case "file.open":
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
		      	break;

		    case "file.save":
				string[] a = ["Kaydet", "İptal"];
      			ResponseType[] r = [ResponseType.GTK_RESPONSE_OK, ResponseType.GTK_RESPONSE_CANCEL];
		      	FileChooserDialog fcd = new FileChooserDialog("File Chooser", this, FileChooserAction.SAVE, a, r);

		      	//fcd.getFileChooser().setSelectMultiple(true);
		      	//fcd.run();

		      	if (fcd.run() == ResponseType.GTK_RESPONSE_OK)
		      	{
		      		int sayfaNo = defter.getCurrentPage();
		      		Widget sayfa = defter.getNthPage(sayfaNo);
		      		SayfaBaslik baslik = cast(SayfaBaslik)defter.getTabLabel(sayfa);

		      		writefln("-> %s, %s", baslik.baslik.getText(), fcd.getFilename());

		      		//SourceBuffer tool = cast(SourceBuffer)defter.getNthPage(sayfaNo);

		      		ScrolledWindow text = cast(ScrolledWindow)defter.getNthPage(sayfaNo);
		      		SourceView kaynak = cast(SourceView)text.getChild();

					writefln("-> %s", kaynak.getBuffer().getText());

		      		File dosya = File(fcd.getFilename(), "wb");
				    dosya.write(kaynak.getBuffer().getText());

		      		writeln("save...");
		      	}
		      	fcd.hide();
		      	break;

			case "help.about":
				(new AboutDialog()).showAll();

//				MessageDialog d = new MessageDialog(
//						this,
//						GtkDialogFlags.MODAL,
//						MessageType.INFO,
//						ButtonsType.OK,
//						"DUI D (graphic) User Interface\n"
//						"an implementation through GTK+\n"
//						"by Antonio Monteiro.\n"
//						"DUI is released under the LGPL license\n"
//						"\n"
//						"Send comments and suggestions to gtkDoolkit@yahoo.ca\n"
//						"or go to the yahoo group\n"
//						"http://groups.yahoo.com/group/gtkDoolkit\n"
//						"(Group email: gtkDoolkit@yahoogroups.com)\n"
//						"\n"
//						"See detailed information at DUI home page\n"
//						"http://ca.geocities.com/gtkDoolkit\n"
//						);
//				d.run();
//				d.destroy();
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

		writefln("Notebook switch to page %s, %s", sekmeNo, sb.getModified());

		// fullCollect helps finding objects that shouldn't have been collected\r
		//std.gc.fullCollect();

		//MessageDialog d = new MessageDialog(this, GtkDialogFlags.MODAL, MessageType.INFO, ButtonsType.OK, "You pressed menu item ");
		//d.run();
		//d.destroy();
	}

	private Widget AnaMenuHazirla()
    {
    	MenuBar menuBar = new MenuBar();   // name is self explanatory

    	Menu mnDosya = menuBar.append("_Dosya");
    	mnDosya.append(new MenuItem("Yeni                      Ctrl+Y"));
    	mnDosya.append(new MenuItem("Aç"));
    	mnDosya.append(new MenuItem("Kaydet"));
    	mnDosya.append(new MenuItem("Farklı Kaydet"));
    	mnDosya.append(new MenuItem("Kapat"));

		return menuBar;

    	/*
		Menu menu;      // idem
    	menu = menubar.append("_Dosya");
    	menu = menubar.append("_Düzen");
    	menu = menubar.append("_Görünüm");
	   	menu.append(new MenuItem("Deneme"));
		//menu.append(new MenuItem(&myMenuItemListener, "E_xit"));

    	//menu.append(new MenuItem(myMenuItemListener, "E_xit","file.exit"));
    	return menubar;
    	/*
		Button btnKapat = new Button();
		btnKapat.setLabel("< Kapat >");
		btnKapat.addOnClicked(&ProgramiKapat);
		return btnKapat;
		*/
    }

	void onWitgetActivate(Widget widget)
	{
		//
	}

	private void ProgramiKapat(Button btn)
	{
		Main.quit();
	}
}



//=========================================================================================================

public class SayfaBaslik : HBox
{
	public ToolButton _kapat;
	public Notebook _defter;
	public Label baslik;
	private string _dosyaAdresi;
	private static int test;

	public this(string tabEtiketi, Notebook defter, Widget sayfa)
	{
		super(false, 0);
		_defter = defter;
		_dosyaAdresi = tabEtiketi;

		++test;

		BaslikHazirla(tabEtiketi, sayfa);
	}

	private void BaslikHazirla(string etiket, Widget sayfa)
	{
		Image img = new Image();
		img.setFromFile("E:\\Proje - D\\Divid\\tab_kapat.png");

		baslik = new Label("   " ~ DosyaAdiDuzenle(etiket) ~ "     ");
		baslik.setSelectable(0);

		_kapat = new ToolButton(img, "");
		_kapat.addOnClicked(&OnSekmeKapat);
		//_kapat.setLabel(to!string(_defter.getNPages()));
		
		//Widget sayfa = _defter.getNthPage(_defter.getNPages());
		_kapat.setData("tabIndex", cast(void*)sayfa);



		this.packStart(baslik, false, false, 0);
        this.packStart(_kapat, false, false, 0);
        this.showAll();
	}

	private void OnSekmeKapat(ToolButton btn)
	{
		int sayfaNo = _defter.pageNum(cast(Widget)btn.getData("tabIndex"));
		_defter.removePage(sayfaNo);
	}

	private string DosyaAdiDuzenle(string dosyaAdresi)
	{
		string dosyaAdi = dosyaAdresi;

		int sonAyracKonumu = lastIndexOf(dosyaAdresi, '\\');

		if (sonAyracKonumu > 0)
		{
			dosyaAdi = dosyaAdresi[sonAyracKonumu + 1 .. dosyaAdresi.length];
			dosyaAdi = leftJustify(dosyaAdi, 15, ' ');
		}

		return dosyaAdi;
	}

	@property string DosyaAdresi() const
	{
		return _dosyaAdresi;
	}
}