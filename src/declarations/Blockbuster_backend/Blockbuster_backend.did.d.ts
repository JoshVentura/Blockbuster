import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface Articulo {
  'id' : string,
  'nombre' : string,
  'tipo' : string,
  'disponible' : boolean,
}
export interface Prestamo {
  'id' : string,
  'tarifaExtra' : bigint,
  'activo' : boolean,
  'fechaDevolucion' : string,
  'usuarioId' : string,
  'fechaPrestamo' : string,
  'articuloId' : string,
}
export interface Usuario {
  'id' : string,
  'nombre' : string,
  'prestamos' : Array<string>,
  'email' : string,
  'telefono' : bigint,
}
export type registroMov = { 'ok' : string } |
  { 'err' : string };
export interface _SERVICE {
  'borrarArticulo' : ActorMethod<[string, string], registroMov>,
  'borrarUsuario' : ActorMethod<[string, string], registroMov>,
  'devolverArticulo' : ActorMethod<[bigint], registroMov>,
  'editarArticulo' : ActorMethod<[string, string, string, string], registroMov>,
  'editarUsuario' : ActorMethod<
    [string, string, string, string, bigint],
    registroMov
  >,
  'obtenerArticulo' : ActorMethod<[bigint], [] | [Articulo]>,
  'obtenerPrestamo' : ActorMethod<[bigint], [] | [Prestamo]>,
  'obtenerUsuario' : ActorMethod<[bigint], [] | [Usuario]>,
  'pagarPrestamo' : ActorMethod<[bigint], registroMov>,
  'prestarArticulo' : ActorMethod<[bigint, bigint], registroMov>,
  'registrarArticulo' : ActorMethod<[string, string, string], registroMov>,
  'registrarUsuario' : ActorMethod<
    [string, string, string, bigint],
    registroMov
  >,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
