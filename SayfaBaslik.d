module SayfaBaslik;

import std.string;

import gtk.HBox, gtk.ToolButton, gtk.Notebook, gtk.Label, gtk.Widget, gtk.Image;

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
		img.setFromFile("resim\\tab_kapat.png");

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