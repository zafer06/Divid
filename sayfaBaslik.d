module SayfaBaslik;

import std.string, std.path;

import gtk.HBox, gtk.ToolButton, gtk.Notebook, gtk.Label, gtk.Widget, gtk.Image;

version (Windows)
{
	enum kapatResmiAdresi = "resim\\tab_kapat.png";
}

version (linux)
{
	enum kapatResmiAdresi = "resim/tab_kapat.png";
}


public class SayfaBaslik : HBox
{
	public ToolButton _kapat;
	public Notebook _defter;
	private Label lblDosyaAdi;
	private string _dosyaAdi;
	private string _dosyaAdresi;

	public this(string tabEtiketi, Notebook defter, Widget sayfa)
	{
		super(false, 0);
		_defter = defter;
		_dosyaAdresi = tabEtiketi;

		BaslikHazirla(tabEtiketi, sayfa);
	}

	private void BaslikHazirla(string etiket, Widget sayfa)
	{
		Image img = new Image();
		img.setFromFile(kapatResmiAdresi);

		_dosyaAdi = DosyaAdiDuzenle(etiket);
		lblDosyaAdi = new Label("   " ~ _dosyaAdi ~ "     ");


		_kapat = new ToolButton(img, "");
		_kapat.addOnClicked(&OnSekmeKapat);
		//_kapat.setLabel(to!string(_defter.getNPages()));
		_kapat.setData("tabIndex", cast(void*)sayfa);



		this.packStart(lblDosyaAdi, false, false, 0);
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
		string dosyaAdi = baseName(dosyaAdresi);
		
		return leftJustify(dosyaAdi, 15, ' ');
	}

	@property string VerDosyaAdresi() const
	{
		return _dosyaAdresi;
	}

	@property void 	YapDosyaAdresi(string dosyaAdresi)
	{
		_dosyaAdresi = dosyaAdresi;
		_dosyaAdi = "   " ~ DosyaAdiDuzenle(_dosyaAdresi) ~ "     ";
		
		lblDosyaAdi.setText(_dosyaAdi);
	}

	@property string VerDosyaAdi() const
	{
		return _dosyaAdi;
	}
}
