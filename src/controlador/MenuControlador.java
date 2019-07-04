
package controlador;

import javax.swing.JButton;
import vista.FrmMenu;

public class MenuControlador implements IControlador {
    
    private final FrmMenu frmMenu;
    
    private JButton btnOperario;
    private JButton btnMiSilla;
    
    public MenuControlador() {
        frmMenu = new FrmMenu();
        
        btnOperario = (JButton) getComponentByName("btnOperario", frmMenu);
        btnOperario.addActionListener(evt -> {
            frmMenu.dispose();
            MenuBancoControlador menuBancoControlador = new MenuBancoControlador();
        });
        
        btnMiSilla = (JButton) getComponentByName("btnMiSilla", frmMenu);
        btnMiSilla.addActionListener(evt -> {
            frmMenu.dispose();
            MenuMiSillaControlador menuMiSillaControlador = new MenuMiSillaControlador();
        });
        
        mostrar();
    }
    
    private void mostrar() {
        frmMenu.setLocationRelativeTo(null);
        frmMenu.setVisible(true);
    }
    
}
