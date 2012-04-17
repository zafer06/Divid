module editor;

import std.stdio;
import std.file;
import std.conv;

import gtk.MainWindow, gtk.Main, gtk.Button, gtk.Label, gtk.VBox, gtk.HBox, gtk.Widget, gtk.ScrolledWindow, gtk.Notebook, gtk.Frame;
import gtk.Image, gtk.RcStyle, gtk.Box, gtk.ToolButton;
import gsv.SourceView, gsv.SourceBuffer, gsv.SourceLanguage, gsv.SourceLanguageManager, gsv.SourceBuffer;
import gsv.SourceStyleSchemeManager, gsv.SourceStyleScheme;
import gtk.MenuBar, gtk.Menu, gtk.MenuItem;
import gtk.FileChooserDialog;

import gtk.AboutDialog, gtk.MessageDialog;

import gtkc.gdktypes;

class Editor : MainWindow
{
	private Notebook defter;

	public this()
	{
		super("Divid Metin Editörü (Geliştiriciler için) -- 0.1 (alfa)");
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
		
		defter.appendPage(MetinEditoruHazirla("editor.d"), new SayfaBaslik("editor.d", defter));
		defter.appendPage(MetinEditoruHazirla("sekme.d"), new SayfaBaslik("sekme.d", defter)); 
		
		defter.appendPage(MetinEditoruHazirla("sekme.d"), new SayfaBaslik("BaskaTest", defter));

	}

	private Widget MetinEditoruHazirla(string dosyaAdi)
    {
        SourceView metinEditoru = new SourceView();
        metinEditoru.setShowLineNumbers(true);
        
        metinEditoru.setInsertSpacesInsteadOfTabs(false);
        metinEditoru.setTabWidth(4);
        metinEditoru.setHighlightCurrentLine(true);
        //metinEditoru.setIndentWidth(10);
    
        SourceBuffer sb = metinEditoru.getBuffer();
        if (dosyaAdi != "bos")
        	sb.setText(cast(string)std.file.read(dosyaAdi));
        
        assert(sb !is null, "-> sb null");

        ScrolledWindow scWindow = new ScrolledWindow();
        scWindow.add(metinEditoru);
        
        SourceLanguageManager slm = new SourceLanguageManager();
        SourceLanguage dLang = slm.getLanguage("d");

 		SourceStyleSchemeManager sssm = new SourceStyleSchemeManager();
        string[] styleSearchPaths = ["E:\\Proje - D\\Divid\\sablon\\styles"];
        sssm.setSearchPath(styleSearchPaths);

        SourceStyleScheme sCheme = sssm.getScheme("oblivion");
        sb.setStyleScheme(sCheme);

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
		menu.append(new MenuItem(&OnMenuKomutuCalistir, "_Close","file.close"));
		menu.append(new MenuItem(&OnMenuKomutuCalistir, "E_xit","file.exit"));
		
		
		menu = menuBar.append("_Edit");
		menu.append(new MenuItem(&OnMenuKomutuCalistir,"_Find","edit.find"));
		menu.append(new MenuItem(&OnMenuKomutuCalistir,"_Search","edit.search"));

		menu = menuBar.append("_Help");
		menu.append(new MenuItem(&OnMenuKomutuCalistir,"_About","help.about"));
		
		return menuBar;
	}

	void OnMenuKomutuCalistir(MenuItem menuItem)
	{
		string action = menuItem.getActionName();
		switch( action )
		{
			case "file.new":
				defter.appendPage(MetinEditoruHazirla("sekme.d"), new SayfaBaslik("sekme.d", defter));
				defter.showAll();
				break;
						
			case "file.open":
				string[] a = ["Aç", "İptal"];
      			ResponseType[] r = [ResponseType.GTK_RESPONSE_OK, ResponseType.GTK_RESPONSE_CANCEL];

		      	FileChooserDialog fcd = new FileChooserDialog("File Chooser", this, FileChooserAction.OPEN, a, r);
		      	//fcd.getFileChooser().setSelectMultiple(true);
		      	fcd.run();
		      	fcd.hide();

		      	string dosyaAdresi = fcd.getFilename();
		      	int gecerliSekmeNo = defter.appendPage(MetinEditoruHazirla(dosyaAdresi), new SayfaBaslik(dosyaAdresi, defter));
		      	defter.showAll();

		      	defter.setCurrentPage(gecerliSekmeNo);
		      	
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
		writefln("Notebook switch to page %s", sekmeNo);
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

	public this(string tabEtiketi, Notebook defter)
	{
		super(false, 0);
		_defter = defter;

		BaslikHazirla(tabEtiketi);
	}

	private void BaslikHazirla(string etiket)
	{
		Image img = new Image();
		img.setFromFile("E:\\Proje - D\\Divid\\tab_kapat.png");

		Label baslik = new Label("   " ~ etiket ~ "     ");

		_kapat = new ToolButton(img, "");
		_kapat.addOnClicked(&OnSekmeKapat);

		packStart(baslik, false, false, 0);
        packStart(_kapat, false, false, 0);
        showAll();
	}

	private void OnSekmeKapat(ToolButton btn)
	{
		_defter.removePage(_defter.getCurrentPage());
	}
}   