export const idlFactory = ({ IDL }) => {
  const registroMov = IDL.Variant({ 'ok' : IDL.Text, 'err' : IDL.Text });
  const Articulo = IDL.Record({
    'id' : IDL.Text,
    'nombre' : IDL.Text,
    'tipo' : IDL.Text,
    'disponible' : IDL.Bool,
  });
  const Prestamo = IDL.Record({
    'id' : IDL.Text,
    'tarifaExtra' : IDL.Nat,
    'activo' : IDL.Bool,
    'fechaDevolucion' : IDL.Text,
    'usuarioId' : IDL.Text,
    'fechaPrestamo' : IDL.Text,
    'articuloId' : IDL.Text,
  });
  const Usuario = IDL.Record({
    'id' : IDL.Text,
    'nombre' : IDL.Text,
    'prestamos' : IDL.Vec(IDL.Text),
    'email' : IDL.Text,
    'telefono' : IDL.Nat,
  });
  return IDL.Service({
    'borrarArticulo' : IDL.Func([IDL.Text, IDL.Text], [registroMov], []),
    'borrarUsuario' : IDL.Func([IDL.Text, IDL.Text], [registroMov], []),
    'devolverArticulo' : IDL.Func([IDL.Int], [registroMov], []),
    'editarArticulo' : IDL.Func(
        [IDL.Text, IDL.Text, IDL.Text, IDL.Text],
        [registroMov],
        [],
      ),
    'editarUsuario' : IDL.Func(
        [IDL.Text, IDL.Text, IDL.Text, IDL.Text, IDL.Nat],
        [registroMov],
        [],
      ),
    'obtenerArticulo' : IDL.Func([IDL.Int], [IDL.Opt(Articulo)], ['query']),
    'obtenerPrestamo' : IDL.Func([IDL.Int], [IDL.Opt(Prestamo)], ['query']),
    'obtenerUsuario' : IDL.Func([IDL.Int], [IDL.Opt(Usuario)], ['query']),
    'pagarPrestamo' : IDL.Func([IDL.Int], [registroMov], []),
    'prestarArticulo' : IDL.Func([IDL.Int, IDL.Int], [registroMov], []),
    'registrarArticulo' : IDL.Func(
        [IDL.Text, IDL.Text, IDL.Text],
        [registroMov],
        [],
      ),
    'registrarUsuario' : IDL.Func(
        [IDL.Text, IDL.Text, IDL.Text, IDL.Nat],
        [registroMov],
        [],
      ),
  });
};
export const init = ({ IDL }) => { return []; };
