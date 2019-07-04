
package controlador;

import vista.FrmMenuBanco;

public class MenuBancoControlador implements IControlador {
    
    private FrmMenuBanco frmMenuBanco;
    
    public MenuBancoControlador() {
        frmMenuBanco = new FrmMenuBanco();
        mostrar();
    }
    
    private void mostrar() {
        frmMenuBanco.setExtendedState(java.awt.Frame.MAXIMIZED_BOTH);
        frmMenuBanco.setVisible(true);
    }
    
}
