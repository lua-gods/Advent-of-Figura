import pretty_midi
import os
import sys

def convert_midi_to_string(midi_file_path, separator=';'):
    midi_data = pretty_midi.PrettyMIDI(midi_file_path)
    notes = []

    # Extract notes from all instruments and add them to a single list with timing information
    for instrument in midi_data.instruments:
        for note in instrument.notes:
            start_time = round(note.start * 20)  # Convert start time to 20th of a second
            notes.append((start_time, note.pitch))

    # Sort the notes by their start time
    notes.sort(key=lambda x: x[0])

    # Now convert the sorted notes to string
    string_representation = ""
    last_time = 0
    for start_time, pitch in notes:
        time_diff = start_time - last_time
        last_time = start_time
        string_representation += f"{time_diff},{pitch}{separator}"

    return string_representation

def process_directory(directory_path):
    for filename in os.listdir(directory_path):
        if filename.lower().endswith('.mid') or filename.lower().endswith('.midi'):
            midi_file_path = os.path.join(directory_path, filename)
            string_representation = convert_midi_to_string(midi_file_path)

            lua_filename = ''.join([c if c.isalnum() else '_' for c in filename.lower()])[:-4] + '.lua'
            lua_filename = '_'.join([w for w in lua_filename.split('_') if w])

            lua_file_path = os.path.join(directory_path, lua_filename)

            with open(lua_file_path, 'w') as lua_file:
                lua_file.write(f"return[[{string_representation}]]")

if __name__ == "__main__":
    directory_path = sys.argv[1] if len(sys.argv) > 1 else '.'
    process_directory(directory_path)
