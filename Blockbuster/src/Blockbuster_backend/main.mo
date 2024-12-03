import HashMap "mo:base/HashMap";
import Time "mo:base/Time";
import Result "mo:base/Result";


// === Declaracion de variables ===

type Articulo ={
  id: Int;
  nombre: Text;
  tipo: Text;
  disponible: Bool;
};

type Usuario ={
  id: Int;
  nombre: Text;
  email: Text;
  telefono: Nat;
  direccion: Text;
  sexo: Text;
  fechaNacimiento: Time;
  prestamos: [Int];
};

type Prestamo ={
  id: Int;
  articuloId: Int;
  usuarioId: Int;
  fechaPrestamo: Time;
  fechaDevolucion: Time;
  tarifaExtra: Nat;
};

var catalogo: HashMap.HashMap<Int, Articulo> = HashMap.HashMap();
var usuarios: HashMap.HashMap<Int, Usuario> = HashMap.HashMap();
var prestamos: HashMap.HashMap<Int, Prestamo> = HashMap.HashMap();

// === Funciones de Admin ===

let adminCode = "0105608"; //Codigo del administrador

//Verifica si el codigo proporcionado es correcto
func verificarAdmin(codigo: Text): Bool {
  return codigo == adminCode;
};

//Registrar un articulo nuevo (Solo Admin)

public func registrarArticulo(codigo: Text, nombre: Text, tipo: Text): Result<Int, Text> {
  
  if(!verificarAdmin(codigo)){
    return Err("Codigo de administrador incorrecto.")
  };

  let id = HashMap.size(catalogo);
  let articulo = {
    id=id, 
    nombre=nombre, 
    tipo=tipo, 
    disponible=true
    ;
  HashMap.put(catalogo, id, articulo);
  return Ok(id);

};

//Registrar usuario nuevo (Solo Admin)

public func registrarUsuario(codigo: Text, nombre: Text, email: Text, telefono: Nat, fechaNacimiento: Time, sexo: Text, direccion: Texto ): Result<Int, Text> {

  if(!verificarAdmin(codigo)){
    return Err("Codigo de administrador incorrecto.");
  };

  let id = HashMap.size(usuarios);
  let usuario = {
    id=id,
    nombre=nombre,
    email=email,
    telefono=telefono,
    fechaNacimiento=fechaNacimiento,
    sexo=sexo,
    direccion=direccion,
    prestamos=[]
  };
  HashMap.put(usuarios, id, usuario);
  return Ok(id);
};

//Editar articulo (Solo Admin)

public func editarArticulo(codigo: Text, articuloId: Int, nombre: Text, tipo: Text): Result<Text, Text> {

  if(!verificarAdmin(codigo)){
    return Err("Codigo de administrador incorrecto.")
  };

  switch (HashMap.get(catalogo, articuloId)){
    case (?articulo){
      HashMap.put(catalogo, articuloId, {...articulo, nombre=nombre, tipo=tipo});
      return Ok("Articulo editado con exito.");
    };
    case(_) {
      return Err("Articulo no encontrado.");
    };
  };
};

//Eliminar articulo (Solo Admin)

public func eliminarArticulo(codigo: Text, articuloId: Int) : Result<Text, Text> {

  if(!verificarAdmin(codigo)) {
    return Err("Codigo de administrador incorrecto.");
  };

  switch (HashMap.get(catalogo, articuloId)) {
    case (?_){
      HashMap.remove(catalogo, articuloId);
      return Ok("Articulo eliminado con exito.")
    };
    case(_){
      return Err("Articulo no encontrado");
    };
  };
};

//Editar usuario (Solo Admin)

public func editarUsuario(codigo: Text, usuarioId: Int, nombre: Text, email: Text, telefono: Nat, fechaNacimiento: Time, sexo: Text, direccion: Text): Result<Text, Text> {

  if(!verificarAdmin(codigo)){
    return Err("Codigo de administrador incorrecto");
  };

  switch(HashMap.get(usuarios, usuariosId)){
    case(?usuarios){
      HashMap.put(usuarios, usuarioId, {
        ...usuario,
        nombre=nombre,
        email=email,
        telefono=telefono,
        fechaNacimiento=fechaNacimiento,
        sexo=sexo,
        direccion=direccion
      });
      return Ok("Usuario editado con exito.");
    };
    case(_){
      return Err("Usuario no encontrado.");
    };
  };
};

//Eliminar usuario (Solo Admin)

public func eliminarUsuario(codigo: Text, usuarioId: Int) : Result<Text, Text>{

  if(!verificarAdmin(codigo)){
    return Err("Codigo de administrador incorrecto");
  };

  switch (HashMap.get(usuarios, usuarioId)){
    case(?_){
      HashMap.remove(usuarios, usuarioId);
      return Ok("Usuario eliminado con exito");
    };
    case(_){
      return Err("Usuario no encontrado.")
    };
  };
};

//===Funciones para la gestion de prestamos===

//Calcular fecha de devolucion

public func calcFechaDev(fechaPrestamo: Time): Time {
  return Time.add(fechaPrestamo, Time.fromDays(5));
};

//Realizar un prestamo

public func prestarArticulo(usuarioId: Int, articuloId: Int): Result<Int, Text>{

  switch (HashMap.get(catalogo, articuloId)){
    case(?articulo) if (articulo.disponible){
      let fechaPrestamo = Time.now():
      let fechaDevolucion = calcFechaDev(fechaPrestamo);
      let idPrestamo = HashMap.size(prestamos)
      let prestamo = {
        id=idPrestamo,
        articuloId=articuloId,
        usuarioId=usuarioId,
        fechaPrestamo=fechaPrestamo,
        fechaDevolucion=fechaDevolucion,
        tarifaExtra=0
      };

      HashMap.put(prestamos, idPrestamos, prestamo);
      HashMap.put(catalogo, articuloId, {...articulo, disponible=false});

      switch (HashMap.ger(usuarios, usuarioId)){
        case(?usuario){
          let usuarioActualizado = {...usuario, prestamos=Array.append(usuario.prestamos,[idPrestamo])};
          HashMap.put(usuarios,usuarioId, usuarioActualizado);
        };
        case(_){
          return Err("Usuario no encontrado.");
        };
      };
      return Ok(idPrestamo);
    };
    case(_){
      return Err("Articulo no disponile.");
    };
  };
};

//Calcular tarifa por retraso de entrega

public func calcTarifaExtra(prestamoId: Int): Nat {
  switch (HashMap.get(prestamos, prestamoId)){
    case(?prestamo){
      let fechaHoy = Time.now();
      if (Time.get(fechaHoy, prestamo.fechaDevolucion)){
        let diasRetraso = Time.toDays(Time.sub(fechaHoy, prestamo.fechaDevolucion));
        return diasRetraso * 15;
      };
      else {
        return 0;
      };
    };
  };
};

//Actualizar tarifa extra en el prestamo

public func actTarifaExtra(prestamoId: Int){
  let tarifa = calcTarifaExtra(prestamoId);
  switch (HashMap.get(prestamos, prestamoId)){
    case(?prestamo){
HashMap.put(prestamos, prestamoId,  {...prestamo, tarifaExtra=tarifa});
    };
    case(_) {};
  };
};

//Obtener datos de un usuario

public func obtenerUsuario(usuarioId: Int): Result<Usuario, Text>{
  switch(HashMap.get(usuarios, usuarioId)){
    case(?usuario){
      return Ok(usuario);
    };
    case(_){
      return Err("Usuario no encontrado.");
    };
  };
};

//Obtener datos de un articulo

public func obtenerArticulo(articuloId: Int): Result<Articulo, Text>{
  switch(HashMap.get(catalogo, articuloId)){
    case(?articulo){
      return Ok(articulo);
    };
    case(_){
      return Err("Articulo no encontrado.");
    };
  };
};

//Obtener todos los usuarios

public func obtenerAllUsuarios(): [Usuario]{
  return HashMap.values(usuarios);
};

//Obtener todos los articulos

public func obtenerAllArticulos(): [Articulo]{
  return HashMap.values(catalogo);
};