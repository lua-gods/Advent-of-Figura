import mido
import os
import sys

def convert_midi_to_string(midi_file_path, separator=';'):
    midi_file = mido.MidiFile(midi_file_path)
    string_representation = ""
    last_time = 0
    current_tempo = 500000  # Default MIDI tempo (120 BPM)

    for track in midi_file.tracks:
        current_time = 0
        for msg in track:
            current_time += msg.time

            if msg.type == 'set_tempo':
                current_tempo = msg.tempo  # Update the current tempo
            elif msg.type == 'note_on' and msg.velocity > 0:
                # Convert ticks to seconds
                seconds = mido.tick2second(current_time, midi_file.ticks_per_beat, current_tempo)
                time_in_20th_seconds = round(seconds * 20)
                time_difference = time_in_20th_seconds - last_time
                last_time = time_in_20th_seconds

                # Append the time difference and MIDI note number to the string
                string_representation += f"{time_difference},{msg.note}{separator}"

    return string_representation

def process_directory(directory_path):
    for filename in os.listdir(directory_path):
        if filename.lower().endswith('.mid') or filename.lower().endswith('.midi'):
            midi_file_path = os.path.join(directory_path, filename)
            string_representation = convert_midi_to_string(midi_file_path)

            lua_filename = os.path.splitext(filename)[0] + '.lua'
            lua_file_path = os.path.join(directory_path, lua_filename)
            with open(lua_file_path, 'w') as lua_file:
                lua_file.write(f"return[[{string_representation}]]")

if __name__ == "__main__":
    directory_path = sys.argv[1] if len(sys.argv) > 1 else '.'
    process_directory(directory_path)

# thank you chatgpt :3