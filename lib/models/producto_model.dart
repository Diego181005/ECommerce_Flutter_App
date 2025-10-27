class Producto {
  final int id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String imageUrl;
  // Añadimos el nombre de la empresa para saber quién lo vende
  final String empresaNombre; 

  Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.imageUrl,
    required this.empresaNombre,
  });

  // --- FÁBRICA CORREGIDA ---
  // Hacemos que sea más segura contra valores 'null'
  // y que coincida con las mayúsculas/minúsculas de tu API
  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'] ?? 0, // Valor por defecto si es nulo
      
      nombre: json['nombre'] ?? 'Sin Nombre', 
      
      descripcion: json['descripcion'] ?? '', 
      
      precio: (json['precio'] as num? ?? 0.0).toDouble(), 
      
      // --- ¡LA CORRECCIÓN ESTÁ AQUÍ! ---
      // La API envía 'imagenUrl' (con 'I' mayúscula)
      // Usamos un placeholder si es nulo
      imageUrl: json['imagenUrl'] ?? 'https://placehold.co/600x400/EEE/B9B9B9?text=Sin+Imagen',
      
      // La API envía 'nombreEmpresa' (con 'N' mayúscula)
      empresaNombre: json['nombreEmpresa'] ?? 'Sin Empresa', 
    );
  }
} 