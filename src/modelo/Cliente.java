
package modelo;

import base_datos.IDBConnection;
import java.util.ArrayList;
import java.sql.*;

public class Cliente implements IDBConnection {
    
    private int id;
    private TipoCliente tipoCliente;
    private String numeroDocumento;
    private String nombres;
    private String apellidoPaterno;
    private String apellidoMaterno;
    private String fecha_nacimiento;
    private String direccion;
    private String correo;
    private String telefono;
    private boolean estado;
    private ArrayList<Cuenta> cuentas;
    private ArrayList<Prestamo> prestamos;
    private ArrayList<MovimientoFrecuente> movimientosFrecuentes;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public TipoCliente getTipoCliente() {
        return tipoCliente;
    }

    public void setTipoCliente(TipoCliente tipoCliente) {
        this.tipoCliente = tipoCliente;
    }

    public String getNumeroDocumento() {
        return numeroDocumento;
    }

    public void setNumeroDocumento(String numeroDocumento) {
        this.numeroDocumento = numeroDocumento;
    }

    public String getNombres() {
        return nombres;
    }

    public void setNombres(String nombres) {
        this.nombres = nombres;
    }

    public String getApellidoPaterno() {
        return apellidoPaterno;
    }

    public void setApellidoPaterno(String apellidoPaterno) {
        this.apellidoPaterno = apellidoPaterno;
    }

    public String getApellidoMaterno() {
        return apellidoMaterno;
    }

    public void setApellidoMaterno(String apellidoMaterno) {
        this.apellidoMaterno = apellidoMaterno;
    }

    public String getFecha_nacimiento() {
        return fecha_nacimiento;
    }

    public void setFecha_nacimiento(String fecha_nacimiento) {
        this.fecha_nacimiento = fecha_nacimiento;
    }

    public String getDireccion() {
        return direccion;
    }

    public void setDireccion(String direccion) {
        this.direccion = direccion;
    }

    public String getCorreo() {
        return correo;
    }

    public void setCorreo(String correo) {
        this.correo = correo;
    }

    public String getTelefono() {
        return telefono;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }

    public boolean isEstado() {
        return estado;
    }

    public void setEstado(boolean estado) {
        this.estado = estado;
    }

    public ArrayList<Cuenta> getCuentas() {
        return cuentas;
    }

    public void setCuentas(ArrayList<Cuenta> cuentas) {
        this.cuentas = cuentas;
    }

    public ArrayList<Prestamo> getPrestamos() {
        return prestamos;
    }

    public void setPrestamos(ArrayList<Prestamo> prestamos) {
        this.prestamos = prestamos;
    }

    public ArrayList<MovimientoFrecuente> getMovimientosFrecuentes() {
        return movimientosFrecuentes;
    }

    public void setMovimientosFrecuentes(ArrayList<MovimientoFrecuente> movimientosFrecuentes) {
        this.movimientosFrecuentes = movimientosFrecuentes;
    }
    
    public ArrayList<Cliente> obtenerListaClientes() {
        ArrayList<Cliente> clientes = new ArrayList<>();
        try (Connection connection = conectarBD(); ResultSet rs = connection.createStatement().executeQuery("SELECT * FROM cliente;")) {
            while (rs.next()) {
                Cliente c = new Cliente();
                c.setId(rs.getInt("id"));
                clientes.add(c);
            }
        } catch (Exception e) {
        }
        return clientes;
    }
    
}
