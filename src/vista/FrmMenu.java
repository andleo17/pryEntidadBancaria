
package vista;

public class FrmMenu extends javax.swing.JFrame {

    public FrmMenu() {
        initComponents();
    }

    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {
        java.awt.GridBagConstraints gridBagConstraints;

        jLabel1 = new javax.swing.JLabel();
        btnOperario = new javax.swing.JButton();
        btnMiSilla = new javax.swing.JButton();

        setDefaultCloseOperation(javax.swing.WindowConstants.EXIT_ON_CLOSE);
        setPreferredSize(new java.awt.Dimension(400, 200));
        setSize(new java.awt.Dimension(400, 300));
        getContentPane().setLayout(new java.awt.GridBagLayout());

        jLabel1.setText("Escoja el rol");
        gridBagConstraints = new java.awt.GridBagConstraints();
        gridBagConstraints.gridx = 0;
        gridBagConstraints.gridy = 0;
        gridBagConstraints.gridwidth = 3;
        gridBagConstraints.weighty = 0.5;
        getContentPane().add(jLabel1, gridBagConstraints);

        btnOperario.setText("Operario de banco");
        gridBagConstraints = new java.awt.GridBagConstraints();
        gridBagConstraints.gridx = 0;
        gridBagConstraints.gridy = 1;
        gridBagConstraints.weightx = 0.5;
        gridBagConstraints.weighty = 0.5;
        getContentPane().add(btnOperario, gridBagConstraints);

        btnMiSilla.setText("Mi Silla");
        gridBagConstraints = new java.awt.GridBagConstraints();
        gridBagConstraints.gridx = 1;
        gridBagConstraints.gridy = 1;
        gridBagConstraints.weightx = 0.5;
        gridBagConstraints.weighty = 0.5;
        getContentPane().add(btnMiSilla, gridBagConstraints);

        pack();
    }// </editor-fold>//GEN-END:initComponents

    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JButton btnMiSilla;
    private javax.swing.JButton btnOperario;
    private javax.swing.JLabel jLabel1;
    // End of variables declaration//GEN-END:variables
}
