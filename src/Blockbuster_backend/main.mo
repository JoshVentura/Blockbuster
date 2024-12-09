//Proyecto creado por Joshua Gustavo Diaz Ventura

/* Este proyecto es un sistema de prestamo de Articulos donde podemos registrar/editar/borrar los articulos y usuarios,
para poder hacer estas funciones se necesita un codigo de admin para que solo la persona que tenga este codigo (gerente del
negocio de prestamos) pueda hacer estos movimientos, EL CODIGO ES 0105608.
el programa tiene funciones para verificar que cada usuario/articulo/prestamo exista, ademas de que cada que se presta
un articulo existente a un usuario existente verifica que el articulo este disponible para dicho prestamo
y da una fecha de 5 dias para poder regresar el articulo, al momento de regresar el articulo el sistema verifica
que haya sido entregado antes de la fecha limite, y en caso de que no, se aplica una tarifa extra que debe ser pagada antes
de hacer la devolucion. */

import Int "mo:base/Int";
import Text "mo:base/Text";
import Time "mo:base/Time";
import HashMap "mo:base/HashMap";
import Result "mo:base/Result";
import Array "mo:base/Array";
import DateTime "mo:datetime/DateTime";
 

actor Blockbuster {

//==Creacion de tipos==
    type Articulo ={
        id: Text;
        nombre: Text;
        tipo: Text;
        disponible: Bool
    };

    type Usuario ={
        id: Text;
        nombre: Text;
        email: Text;
        telefono: Nat;
        prestamos: [Text];
    };

    type Prestamo ={
        id: Text;
        articuloId: Text;
        usuarioId: Text;
        fechaPrestamo: Text;
        fechaDevolucion: Text;
        tarifaExtra: Nat;
        activo: Bool;
    };

//==Creacion de HashMaps==

    let usuariosMap = HashMap.HashMap<Text, Usuario>(0, Text.equal, Text.hash);
    let articulosMap = HashMap.HashMap<Text, Articulo>(0, Text.equal, Text.hash);
    let prestamosMap = HashMap.HashMap<Text, Prestamo>(0, Text.equal, Text.hash);

//==Variables para asegurar ids unicos==

    var idArticulo: Int = 0;
    var idUsuario: Int = 0;
    var idPrestamo: Int = 0;

    func generarIdArticulo(): Int {idArticulo += 1; idArticulo};
    func generarIdUsuario(): Int {idUsuario += 1; idUsuario};
    func generarIdPrestamo(): Int {idPrestamo += 1; idPrestamo};

//=Codigo de Admin

    let adminCode = "0105608";

//==Results para Ok y Err==

    type registroMov = Result.Result<Text, Text>; 

//==Funcion para verificar que el codigo ingresado sea el correcto==

    func verificarAdmin(codigo: Text): Bool{
        return codigo == adminCode;
    };

//==Funciones para registrar Usuarios/Articulos==

    public func registrarArticulo(codigo: Text, nombre: Text, tipo: Text): async registroMov{
        if(verificarAdmin(codigo)){
            let disponible = true;
            let id: Text = Int.toText(generarIdArticulo());
            let articulo ={
                id;
                nombre;
                tipo;
                disponible
            };

            articulosMap.put(id, articulo);

        return #ok("Articulo registrado con exito, ID del usuario:" # id);
        }
     else{
        return #err("La clave ingresada es incorrecta.");
        };
    };

    public func registrarUsuario(codigo: Text, nombre: Text, email: Text, telefono: Nat): async registroMov{
        if(verificarAdmin(codigo)){
            let id: Text = Int.toText(generarIdUsuario());
            let usuario ={
                id;
                nombre;
                email;
                telefono;
                prestamos = [];
            };

            usuariosMap.put(id, usuario);
            return #ok("Usuario registrado con exito, ID del usuario:" # id);
        }
        else{
            return #err("La clave ingresada es incorrecta.");
        }

    };

//==Funciones para editar Usuarios/Articulos==


    public func editarArticulo(codigo: Text, id: Text, nombre: Text, tipo: Text): async registroMov{
        if(verificarAdmin(codigo)){
            let articule: ?Articulo = articulosMap.get(id);
            switch(articule){
                case(?articuleOk){
                    let articulo ={
                        id;
                        nombre;
                        tipo;
                        disponible = articuleOk.disponible;
                    };
                    articulosMap.put(id, articulo);
                    return #ok("Articulo editado con exito.");
                };
                case(null){
                    return #err("Articulo no encontrado.")
                };
            };
        }
        else{

        return #err("La clave ingresada es incorrecta.");
        };
    };

    public func editarUsuario(codigo: Text, id: Text, nombre: Text, email: Text, telefono: Nat): async registroMov{
        if(verificarAdmin(codigo)){
            let user: ?Usuario = usuariosMap.get(id);
            switch(user){
                case(?userOk){
                    let usuario ={
                        id;
                        nombre;
                        email;
                        telefono;
                        prestamos = userOk.prestamos;
                    };
                    usuariosMap.put(id, usuario);
                    return #ok("Usuario editado con exito.");
                };
                case(null){
                    return #err("Usuario no encontrado.");
                };
            };
        }
        else{
            return #err("La clave ingresada es incorrecta.");
        };
    };

//==Borrar Usuarios/Articulos==

    public func borrarArticulo(codigo: Text, id: Text): async registroMov{
        if(verificarAdmin(codigo)){
            let articul: ?Articulo = articulosMap.get(id);
            switch(articul){
                case(null){
                    return #err("Articulo no encontrado");
                };
                case(_) {
                    ignore articulosMap.remove(id);
                    return #ok("Articulo borrado exitosamente");
                };
            };
        }
        else{
        return #err("La clave ingresada es incorrecta");
        };
    };

    public func borrarUsuario(codigo: Text, id: Text): async registroMov{
        if(verificarAdmin(codigo)){
         let user: ?Usuario = usuariosMap.get(id);
            switch(user){
                case(null){
                    return #err("Usuario no encontrado");
                    };
                case(_){
                    ignore usuariosMap.remove(id);
                    return #ok("Usuario borrado exitosamente.");
                };
            };
        }
        else{
            return #err("La clave ingresada es incorrecta");
        };
    };

//==Regresar info de Usuarios/Articulos dependiendo del ID==

    public query func obtenerArticulo(id: Int): async ?Articulo{
        let articuloId: Text = Int.toText(id);
        articulosMap.get(articuloId);
    };

    public query func obtenerUsuario(id: Int): async ?Usuario{
        let usuarioId: Text = Int.toText(id);
        usuariosMap.get(usuarioId);
    };

//La funcion para visualizar el prestamo llama a funciones para verificar las fechas y establecer el precio por entrega tardia

    public query func obtenerPrestamo(id: Int): async ?Prestamo{
        let prestamoId: Text = Int.toText(id);
        let prestamos: ?Prestamo = prestamosMap.get(prestamoId);
            switch(prestamos){
                case(?prestamosOk){
                    if(compararFechas(prestamosOk.fechaDevolucion)){
                        prestamosMap.get(prestamoId);
                    }
                    else{
                        let prestamos ={
                                id =prestamosOk.id;
                                articuloId = prestamosOk.articuloId;
                                usuarioId = prestamosOk.usuarioId;
                                fechaPrestamo = prestamosOk.fechaPrestamo;
                                fechaDevolucion = prestamosOk.fechaDevolucion;
                                tarifaExtra: Nat=15;
                                activo = prestamosOk.activo;
                                };
                                prestamosMap.put(prestamoId, prestamos);
                                return prestamosMap.get(prestamoId);
                    };
                };
                case(_){
                    return prestamosMap.get(prestamoId);
                };
            };
    };

//==Realizar Prestamo==

//Funcion que verifica que el articulo que se va a prestar este disponible
    func estaDisponible(id: Text): Bool{
        switch(articulosMap.get(id)){
            case(null){
                return false;
            };
            case(?articul){
               return articul.disponible;
            };
        };
    };


//Funcion que obtiene la fecha actual en la cual se hace el prestamo
    private func obtenerHoy(): Text{
        let hoy = Time.now();
        let dateTime = DateTime.DateTime(hoy);
        return dateTime.toText();
    };

//Funcion que obtiene la fecha en la cual se tiene que devolver el articulo
    private func obtenerFDev(): Text{
        let hoy = Time.now();
        let cincoDias = 5 * 24 * 60 * 60 * 1_000_000_000;
        let fechaFut = hoy + cincoDias;
        let fechaDev = DateTime.DateTime(fechaFut);
        return fechaDev.toText();
    };


    public func prestarArticulo(uId: Int, aId: Int): async registroMov{
        let articuloId: Text = Int.toText(aId);
        let usuarioId: Text = Int.toText(uId);
        let articule: ?Articulo = articulosMap.get(articuloId);
        let user: ?Usuario = usuariosMap.get(usuarioId);
        switch(articule){
            case(null){
                return #err("El articulo seleccionado no existe, favor verifique e intente de nuevo");
            };
            case(?articuleOk){
                switch(user){
                    case(null){
                        return #err("El usuario seleccionado no existe, favor verifique e intente de nuevo");
                    };
                    case(?userOk){
                        if(estaDisponible(articuloId)){
                        let fechaPrestamo = obtenerHoy();
                        let fechaDevolucion = obtenerFDev();
                        let id: Text = Int.toText(generarIdPrestamo());
                        let prestamo ={
                            id;
                            articuloId;
                            usuarioId;
                            fechaPrestamo;
                            fechaDevolucion;
                            tarifaExtra: Nat=0;
                            activo = true;
                        };
                        let usuario ={
                            id=usuarioId;
                            nombre = userOk.nombre;
                            email = userOk.email;
                            telefono = userOk.telefono;
                            prestamos = Array.append(userOk.prestamos,[id]);
                        };
                        let articulo ={
                        id = articuloId;
                        nombre = articuleOk.nombre;
                        tipo = articuleOk.tipo;
                        disponible = false;
                        };
                        prestamosMap.put(id, prestamo);
                        usuariosMap.put(usuarioId, usuario);
                        articulosMap.put(articuloId, articulo);
                        return #ok("Prestamo efectuado con exito, ID del prestamo:" # id);
                        }
                        else{
                            return #err("Lo sentimos, el articulo seleccionado no esta disponible para prestamo.");
                        };
                        
                    };
                };

            };
            
        };
        
    };


//==Realizar devolucion==


//Funcion que verifica que el prestamo sigue activo, para evitar regresar prestamos ya finalizados
    func prestamoActivo(id: Text): Bool{
        switch(prestamosMap.get(id)){
            case(null){
                return false;
            };
            case(?prestam){
                return prestam.activo;
            };
        };
    };

//Funcion que compara la fecha acordada de devolucion y la fecha en la que se esta devolviendo el articulo
    func compararFechas(fechaDev: Text): Bool{
        let hoy = Time.now();
        let hoyEnTexto = Int.toText(hoy);
        return Text.greater(fechaDev ,hoyEnTexto);
    };  

//Funcion que verifica si ya fue pagada la tarifa por entrega tardia si se da el caso
    func verificarPagado(id: Text): Bool{
        switch(prestamosMap.get(id)){
            case(null){
                return false;
            };
            case(?prestam){
                if(prestam.tarifaExtra == 0){
                    return false;
                }
                else{
                    return true;
                };
            };
        };
    };

//Funcion que permite pagar la tarifa por entrega tardia en caso de que exista
    public func pagarPrestamo(pId: Int): async registroMov{
        let prestamoId: Text = Int.toText(pId);
        let prestamos: ?Prestamo = prestamosMap.get(prestamoId);
        switch(prestamos){
            case(null){
                return #err("El prestamo no existe, intente de nuevo");
            };
            case(?prestamoOk){
                if(verificarPagado(prestamoId)){
                    return #ok("Prestamo sin pagos pendientes");
                }
                else{
                    let prestamos ={
                        id =prestamoOk.id;
                        articuloId = prestamoOk.articuloId;
                        usuarioId = prestamoOk.usuarioId;
                        fechaPrestamo = prestamoOk.fechaPrestamo;
                        fechaDevolucion = prestamoOk.fechaDevolucion;
                        tarifaExtra: Nat=0;
                        activo = prestamoOk.activo;
                        };
                    prestamosMap.put(prestamoId, prestamos);
                    return #ok("Prestamo pagado exitosamente");
                };
            };
        };
    };

//Funcion para devolver el articulo
    public func devolverArticulo(pId: Int): async registroMov{
        let prestamoId: Text = Int.toText(pId);
        let prestamos: ?Prestamo = prestamosMap.get(prestamoId);
        switch(prestamos){
            case(null){
                return #err("El prestamo no existe");
            };
            case(?prestamosOk){
                if(prestamoActivo(prestamoId)){
                    if(verificarPagado(prestamoId)){
                        let articulo: ?Articulo = articulosMap.get(prestamosOk.articuloId);
                        switch(articulo){
                            case(null){
                                return #err("Error, intentelo de nuevo");
                            };
                            case(?articuloOk){
                                let prestamos ={
                                id =prestamosOk.id;
                                articuloId = prestamosOk.articuloId;
                                usuarioId = prestamosOk.usuarioId;
                                fechaPrestamo = prestamosOk.fechaPrestamo;
                                fechaDevolucion = prestamosOk.fechaDevolucion;
                                tarifaExtra: Nat=0;
                                activo = false;
                                };
                                let articule ={
                                id = articuloOk.id;
                                nombre = articuloOk.nombre;
                                tipo = articuloOk.tipo;
                                disponible = true;
                                };
                                prestamosMap.put(prestamoId, prestamos);
                                articulosMap.put(prestamosOk.articuloId, articule);
                                return #ok("Articulo regresado con exito");
                            };
                        };
                        
                    }
                    else{
                        return #err("El prestamo tiene un pago pendiente, por favor haga el pago e intente de nuevo")
                    };
                    
                }
                else{
                    return #err("Este prestamo ya fue devuelto anteriormente");
                };
            };
        };

    };

};

