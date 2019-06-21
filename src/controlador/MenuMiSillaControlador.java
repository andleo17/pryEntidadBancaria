
package controlador;

import vista.FrmMiSilla;

public class MenuMiSillaControlador implements IControlador{
    
    private FrmMiSilla frmMiSilla;
    
    public MenuMiSillaControlador() {
        frmMiSilla = new FrmMiSilla();
        mostrar();
    }
    
    private void mostrar() {
        frmMiSilla.setExtendedState(java.awt.Frame.MAXIMIZED_BOTH);
        frmMiSilla.setVisible(true);
    }
    
}
