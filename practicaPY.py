# Practica Calificada Python
from collections import defaultdict # Ejercicio 5

#1) Limpieza de texto y conteo (strings)
def normalizar_y_contar(texto: str) -> dict:
    texto_normalizado = texto.strip()
    texto_normalizado = texto_normalizado.lower()
    texto_normalizado_sin_comas = texto_normalizado.replace(",", "")
    texto_normalizado_sin_comas = texto_normalizado_sin_comas.split()
    texto_normalizado_sin_comas = " ".join(texto_normalizado_sin_comas)
    array = texto_normalizado_sin_comas.split()

    diccionario = {
        "texto": texto_normalizado,
        "palabras": set(array),
        "total_palabras": len(array),
        "unicas": len(set(array)),

    }

    return diccionario

# 2) Mini–clasificador de números (condicionales + bucles) – 15 pts
def clasificar_numeros(numeros: list[int]) -> dict:
    pares, impares = [],[]
    pos, negs = [],[]
    for numero in numeros:
        if numero % 2 == 0:
            pares.append(numero)
        else:
            impares.append(numero)
        if numero > 0:
            pos.append(numero)
        if numero < 0:
            negs.append(numero)

    diccionario = {
        "pares": pares,
        "impares": impares,
        "pos&neg": [pos,negs],
        "promedio": None,
        "max&min": None,
    }

    if len(numeros) > 0:
        diccionario["promedio"] = sum(numeros) / len(numeros)
        diccionario["max&min"] = [max(numeros), min(numeros)]
    return diccionario


# 3) Gestor simple de lista de tareas (listas + métodos)
def agregar_tarea(tareas: list[str], tarea: str) -> None:
    tarea = tarea.strip()
    if tarea not in tareas:
        tareas.append(tarea)

def eliminar_tarea(tareas: list[str], tarea: str) -> bool:
    tarea = tarea.strip()
    if tarea in tareas:
        tareas.remove(tarea)
        return True
    return False


def priorizar(tareas: list[str], tarea: str, nueva_pos: int) -> bool:
    tarea = tarea.strip()
    if tarea in tareas:
        indice = tareas.index(tarea)
        tarea_pop = tareas.pop(indice)
        tareas.insert(nueva_pos, tarea_pop)
        return True
    return False


def listar_tareas_ordenadas(tareas: list[str]) -> list[str]:
    lista_ordenada = tareas
    return sorted(lista_ordenada)

# 4) Inventario de tienda (diccionarios) 
def stock(inventario: dict[str,int], producto: str) -> int|None:
    return inventario.get(producto)

def abastecer(inventario, producto, cantidad) -> None:
    if producto not in inventario:
        inventario[producto] = cantidad
        return
    inventario[producto] += cantidad

def vender(inventario, producto, cantidad) -> bool:
    if inventario[producto] and inventario[producto] >= cantidad:
        inventario[producto] -= cantidad
        return True
    return False

def reporte(inventario) -> dict:
    productos = []
    for producto, cantidad in inventario.items():
        if cantidad == 0:
            productos.append(producto)
    diccionario = {
        "total_items": sum(inventario.values()),
        "agotados": productos,
        "top": max(inventario.items(), key=lambda x: x[1])

    }
    return diccionario

# 5) Utilidad de funciones: estadísticas de calificaciones 

def promedios_por_estudiante(datos) -> dict[str,float]:
    diccionario = defaultdict(list) # importado

    print(diccionario)
    for estudiante, promedio in datos:
        diccionario[estudiante].append(promedio)

    diccionario_promedio = {}
    for estudiante,promedio in diccionario.items():
        diccionario_promedio[estudiante] = sum(promedio) / len(promedio)

    return diccionario_promedio


def mejor_estudiante(promedios: dict[str,float]) -> tuple[str,float]:
    mejor_estudiante = ''
    mejor_promedio = 0
    for estudiante,promedio in promedios.items():
        if promedio >  mejor_promedio:
            mejor_promedio = promedio
            mejor_estudiante = estudiante

    return (mejor_estudiante,mejor_promedio)



def filtrar_aprobados(promedios, minimo=13) -> dict[str,float]:
    aprobados = {}
    for estudiante,promedio in promedios.items():
        if promedio >  minimo:
            aprobados[estudiante] = promedio
                  
    return aprobados

# 6) Reto creativo (integrador) 

# Ejercicios

# Ejercicio 1
#print(normalizar_y_contar(" Hola, mundo \n Hola Python "))

# Ejercicio 2
#print( clasificar_numeros([-3, -1, 0, 2, 4, 5]))
#print( clasificar_numeros([]))

#Ejercicio 3
'''
tareas = []
agregar_tarea(tareas,  "estudiar" )
print(tareas)
agregar_tarea(tareas,  "comprar pan")
print(tareas)
agregar_tarea(tareas, "pasear al scobydoo")
print(tareas)
priorizar(tareas, "comprar pan", 0)
print(tareas)
eliminar_tarea(tareas, "estudiar" )
print(tareas)
print(listar_tareas_ordenadas(tareas))
'''
#Ejercicio 4
'''
inv = {"manzana": 5, "banana": 2, "pan": 10}
print(reporte(inv))
vender(inv, "pan", 3)
print(reporte(inv))
abastecer(inv, "banana", 5)
print(reporte(inv))
'''
#Ejercico 5
'''
datos = [("Ana", 15), ("Luis", 12), ("Ana", 18), ("Sara", 20), ("Luis", 14)]
proms = promedios_por_estudiante(datos)
print(proms, mejor_estudiante(proms), filtrar_aprobados(proms, 14))
'''

#Ejercico 6
#Opción C – Minijuego: adivina el número
import random

def adivina_el_numero():
    intentos = []
    numero_a_adivinar = random.randint(1,100)
    MAX_intentos = 10
    numero_intentos = MAX_intentos
    while numero_intentos > 0:
        numero_ingresado = input('Ingrese un numero del 1 al 100:')
        # Aca valido que este dentro de el rango
        if not numero_ingresado.isdigit():
            print('Por favor ingrese un numero')
            continue
        numero_ingresado = int(numero_ingresado)

        if numero_ingresado < 1 or numero_ingresado > 100:
            print('Numero fuera de rango')
            continue
        
        if numero_a_adivinar == numero_ingresado:
            print('Felicitaciones, adivinaste el numero')
            print('Estadisticas')
            print('Intentos usados: ', MAX_intentos - numero_intentos )
            print( intentos)

            break

        if numero_a_adivinar < numero_ingresado:
            print('El numero es menor')
        else:
            print('El numero es mayor')

        intentos.append(numero_ingresado)
        numero_intentos -= 1

adivina_el_numero()





