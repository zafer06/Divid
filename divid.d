import gtk.Main;
import Editor;

void main(string[] args)
{
    Main.init(args);
    new Editor();
    Main.run();
}