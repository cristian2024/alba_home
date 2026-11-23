"""Genera los sonidos de alarma del plugin (WAV mono, 22 050 Hz, 16 bits).

Son sonidos propios, sintetizados aquí: no hay archivos de terceros ni
licencias que cumplir. Cada uno dura unos segundos y está pensado para sonar
en bucle; la subida de volumen la hace el programador de alarmas.

    python3 tool/generate_sounds.py
"""

import math
import struct
import wave
from pathlib import Path

RATE = 22050
OUT = Path(__file__).resolve().parent.parent / "assets" / "sounds"


def tone(freq, start, length, decay, partials=((1, 1.0),)):
    """Una nota con armónicos y caída exponencial, como lista de muestras."""
    n = int(length * RATE)
    samples = []
    for i in range(n):
        t = i / RATE
        envelope = math.exp(-t / decay) * min(1.0, t / 0.01)
        value = sum(amp * math.sin(2 * math.pi * freq * mult * t) for mult, amp in partials)
        samples.append(value * envelope)
    return start, samples


def render(notes, total):
    buffer = [0.0] * int(total * RATE)
    for start, samples in notes:
        offset = int(start * RATE)
        for i, value in enumerate(samples):
            if offset + i < len(buffer):
                buffer[offset + i] += value
    peak = max(abs(v) for v in buffer) or 1.0
    return [v / peak * 0.85 for v in buffer]


def write(name, samples):
    OUT.mkdir(parents=True, exist_ok=True)
    with wave.open(str(OUT / f"{name}.wav"), "wb") as file:
        file.setnchannels(1)
        file.setsampwidth(2)
        file.setframerate(RATE)
        file.writeframes(b"".join(struct.pack("<h", int(v * 32767)) for v in samples))


def sunrise():
    # Arpegio mayor que sube (do, mi, sol, do) con armónicos suaves.
    soft = ((1, 1.0), (2, 0.25), (3, 0.08))
    freqs = [523.25, 659.25, 783.99, 1046.50]
    notes = [tone(f, i * 0.45, 2.0, 0.7, soft) for i, f in enumerate(freqs)]
    return render(notes, 4.0)


def bell():
    # Campana: parciales inarmónicos y caída larga, dos golpes.
    partials = ((1, 1.0), (2.76, 0.5), (5.4, 0.25), (8.93, 0.12))
    notes = [tone(587.33, 0.0, 2.5, 0.9, partials), tone(587.33, 1.5, 2.5, 0.9, partials)]
    return render(notes, 3.0)


def pulse():
    # Tres pitidos cortos y una pausa: más insistente.
    beep = ((1, 1.0), (3, 0.2))
    notes = [tone(880.0, i * 0.25, 0.15, 0.08, beep) for i in range(3)]
    return render(notes, 1.5)


if __name__ == "__main__":
    write("sunrise", sunrise())
    write("bell", bell())
    write("pulse", pulse())
    for path in sorted(OUT.glob("*.wav")):
        print(path.name, path.stat().st_size // 1024, "KB")
