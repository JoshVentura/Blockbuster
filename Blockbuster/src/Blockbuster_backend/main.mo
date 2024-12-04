import Int "mo:base/Int";
import Text "mo:base/Text";
import Hash "mo:base/Hash";
import Time "mo:base/Time";
import HashMap "mo:base/HashMap";
import Result "mo:base/Result";
import Array "mo:base/Array";
 

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
        fechaPrestamo: Int;
        fechaDevolucion: Int;
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

        return #ok(id);
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
            return #ok(id);
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

    public query func obtenerArticulo(id: Text): async ?Articulo{
        articulosMap.get(id);
    };

    public query func obtenerUsuario(id: Text): async ?Usuario{
        usuariosMap.get(id);
    };

    public query func obtenerPrestamo(id: Text): async ?Prestamo{
        prestamosMap.get(id);
    };

//==Realizar Prestamo==

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
                        let fechaPrestamo = Time.now()/(24*60*60*1_000_000_000);
                        let fechaDevolucion = Time.now()/(5*24*60*60*1_000_000_000);
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
                        return #ok("Prestamo efectuado con exito");
                        }
                        else{
                            return #err("Lo sentimos, el articulo seleccionado no esta disponible para prestamo.");
                        };
                        
                    };
                };

            };
            
        };
        
    };

};

