import os
import pandas as pd
import tkinter as tk
from tkinter import ttk, messagebox, simpledialog
import pygame
import random
import json

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
BIRDSONG_BASE_DIR = os.path.join(SCRIPT_DIR, '..', 'birdsong')
EXCEL_PATH = os.path.join(BIRDSONG_BASE_DIR, 'birdsong_database.xlsx')
BIRD_LISTS_PATH = os.path.join(SCRIPT_DIR, 'bird_lists.json')

class BirdsongTrainerApp:
    def __init__(self, root):
        self.root = root
        self.root.title('Birdsong Ear Trainer')
        self.df = pd.read_excel(EXCEL_PATH)
        self.filtered_df = self.df.copy()
        self.selected_bird = None
        self.selected_file = None
        self._init_audio()
        self._build_gui()
        self._populate_sound_types()
        self._populate_bird_list()
        # Bird lists
        self.bird_lists = self._load_bird_lists()

    def _init_audio(self):
        pygame.mixer.init(frequency=48000, size=-16, channels=2, buffer=1024)
        pygame.mixer.music.set_volume(0.7)

    def _build_gui(self):
        # Sound type filter
        filter_frame = ttk.Frame(self.root)
        filter_frame.pack(fill='x', padx=10, pady=5)
        ttk.Label(filter_frame, text='Filter by Sound Type:').pack(side='left')
        self.sound_type_var = tk.StringVar()
        self.sound_type_combo = ttk.Combobox(filter_frame, textvariable=self.sound_type_var, state='readonly')
        self.sound_type_combo.pack(side='left', padx=5)
        self.sound_type_combo.bind('<<ComboboxSelected>>', self._on_filter_change)
        # Lists button
        manage_lists_btn = ttk.Button(filter_frame, text='Lists', command=self._open_bird_list_manager)
        manage_lists_btn.pack(side='right', padx=5)
        # Game button
        game_btn = ttk.Button(filter_frame, text='Game', command=self._open_game_mode)
        game_btn.pack(side='right', padx=5)
        # Pause/Stop buttons
        self.is_paused = False
        pause_btn = ttk.Button(filter_frame, text='Pause', command=self._toggle_pause)
        pause_btn.pack(side='right', padx=5)
        stop_btn = ttk.Button(filter_frame, text='Stop', command=self._stop_playback)
        stop_btn.pack(side='right', padx=5)
        self.pause_btn = pause_btn
        # Excel sync button (initially enabled)
        self.sync_needed = True
        self.sync_btn = ttk.Button(filter_frame, text='⟳', width=2, command=self._update_excel, state='normal')
        self.sync_btn.pack(side='right', padx=5)
        self.sync_btn_tip = ttk.Label(filter_frame, text='Update Excel', foreground='red')
        self.sync_btn_tip.pack(side='right', padx=2)
        # Bird list
        bird_frame = ttk.Frame(self.root)
        bird_frame.pack(side='left', fill='y', padx=10, pady=5)
        ttk.Label(bird_frame, text='Birds').pack()
        self.bird_listbox = tk.Listbox(bird_frame, width=30)
        self.bird_listbox.pack(fill='y', expand=True)
        self.bird_listbox.bind('<<ListboxSelect>>', self._on_bird_select)
        # Sound file list as horizontal rows
        sound_frame = ttk.Frame(self.root)
        sound_frame.pack(side='left', fill='both', expand=True, padx=10, pady=5)
        ttk.Label(sound_frame, text='Sound Files').pack()
        self.sound_list_container = ttk.Frame(sound_frame)
        self.sound_list_container.pack(fill='both', expand=True)
        self.selected_bird = None
        self.selected_file = None

    def _populate_sound_types(self):
        # Only show umbrella categories
        umbrella_types = ['All', 'Song', 'Calls', 'Tink Calls', 'Flight Calls', 'Chip Calls']
        self.sound_type_combo['values'] = umbrella_types
        self.sound_type_combo.set('All')

    def _populate_bird_list(self):
        self.bird_listbox.delete(0, tk.END)
        birds = sorted(self.filtered_df['species'].unique())
        for bird in birds:
            self.bird_listbox.insert(tk.END, bird)
        # Do NOT destroy self.sound_list_container here!
        # Just clear the selection and sound list
        for widget in self.sound_list_container.winfo_children():
            widget.destroy()
        self.selected_bird = None
        self.selected_file = None

    def _on_filter_change(self, event=None):
        selected_type = self.sound_type_var.get()
        if selected_type == 'All':
            self.filtered_df = self.df.copy()
        elif selected_type.lower() in ['song', 'calls', 'tink calls', 'flight calls', 'chip calls']:
            keyword = selected_type.lower().replace(' ', '')[:-1] if selected_type.lower().endswith('s') else selected_type.lower().replace(' ', '')
            # Match any sound_type containing the umbrella keyword (case-insensitive, ignore spaces and plural)
            self.filtered_df = self.df[self.df['sound_type'].str.lower().str.replace(' ', '').str.contains(keyword, na=False)]
        else:
            self.filtered_df = self.df[self.df['sound_type'] == selected_type]
        self._populate_bird_list()

    def _on_bird_select(self, event=None):
        selection = self.bird_listbox.curselection()
        if not selection:
            return
        bird = self.bird_listbox.get(selection[0])
        self.selected_bird = bird
        self._populate_sound_list(bird)

    def _populate_sound_list(self, bird):
        # Clear previous widgets
        for widget in self.sound_list_container.winfo_children():
            widget.destroy()
        files = self.filtered_df[self.filtered_df['species'] == bird]['file_name'].tolist()
        for f in files:
            row = ttk.Frame(self.sound_list_container)
            row.pack(fill='x', pady=2)
            play_btn = ttk.Button(row, text='▶', width=3, command=lambda file=f: self._play_file(bird, file))
            play_btn.pack(side='left', padx=2)
            label = ttk.Label(row, text=f, anchor='center')
            label.pack(side='left', fill='x', expand=True)
            del_btn = ttk.Button(row, text='🗑', width=3, command=lambda file=f: self._delete_file(bird, file))
            del_btn.pack(side='right', padx=2)

    def _play_file(self, bird, file):
        file_path = os.path.join(BIRDSONG_BASE_DIR, bird, file)
        if not os.path.exists(file_path):
            messagebox.showerror('Error', f'File not found: {file_path}')
            return
        try:
            pygame.mixer.music.load(file_path)
            pygame.mixer.music.play()
        except Exception as e:
            resp = messagebox.askyesno('Error', f'Could not play file: {e}\n\nWould you like to delete this file?')
            if resp:
                self._delete_file(bird, file)

    def _delete_file(self, bird, file):
        file_path = os.path.join(BIRDSONG_BASE_DIR, bird, file)
        if not os.path.exists(file_path):
            messagebox.showerror('Error', f'File not found: {file_path}')
            return
        resp = messagebox.askyesno('Delete File', f'Are you sure you want to delete this file?\n{file}')
        if resp:
            try:
                os.remove(file_path)
                self._populate_sound_list(bird)
                self._mark_excel_sync_needed()
            except Exception as e:
                messagebox.showerror('Error', f'Could not delete file: {e}')

    def _mark_excel_sync_needed(self):
        self.sync_needed = True
        self.sync_btn.config(state='normal')
        self.sync_btn_tip.config(text='Update Excel')

    def _update_excel(self):
        # Rebuild the Excel file from the current filesystem
        import pandas as pd
        from scientific_names import SCIENTIFIC_NAMES
        rows = []
        warbler_list_path = os.path.join(SCRIPT_DIR, 'warbler_list.txt')
        if os.path.exists(warbler_list_path):
            with open(warbler_list_path) as f:
                birds = [line.strip() for line in f if line.strip()]
        else:
            birds = [d for d in os.listdir(BIRDSONG_BASE_DIR) if os.path.isdir(os.path.join(BIRDSONG_BASE_DIR, d))]
        for bird in birds:
            folder = os.path.join(BIRDSONG_BASE_DIR, bird)
            if not os.path.isdir(folder):
                continue
            for file in os.listdir(folder):
                if file.endswith('.mp3'):
                    scientific = SCIENTIFIC_NAMES.get(bird, '')
                    sound_type = ''
                    match = self.df[(self.df['species'] == bird) & (self.df['file_name'] == file)]
                    if not match.empty:
                        sound_type = match.iloc[0]['sound_type']
                    rows.append({
                        'file_name': file,
                        'species': bird,
                        'scientific_name': scientific,
                        'sound_type': sound_type,
                    })
        df = pd.DataFrame(rows, columns=['file_name', 'species', 'scientific_name', 'sound_type'])
        df.to_excel(EXCEL_PATH, index=False)
        self.df = df
        self.filtered_df = self.df.copy()
        self.sync_needed = False
        self.sync_btn.config(state='disabled')
        self.sync_btn_tip.config(text='')
        messagebox.showinfo('Excel Updated', 'birdsong_database.xlsx has been updated to match the filesystem.')

    def _open_game_mode(self):
        game_win = tk.Toplevel(self.root)
        game_win.title('Game Mode')
        ttk.Label(game_win, text='Choose a game mode:').pack(pady=10)
        # Bird list dropdown
        list_frame = ttk.Frame(game_win)
        list_frame.pack(pady=5)
        ttk.Label(list_frame, text='Bird List:').pack(side='left')
        bird_list_names = [''] + list(self.bird_lists.keys())
        selected_list = tk.StringVar(value='')
        list_combo = ttk.Combobox(list_frame, textvariable=selected_list, values=bird_list_names, state='readonly')
        list_combo.pack(side='left', padx=5)
        # Start game buttons
        quiz_btn = ttk.Button(game_win, text='Quiz', command=lambda: [game_win.destroy(), self._start_quiz_mode(selected_list.get())])
        quiz_btn.pack(pady=5)
        listen_btn = ttk.Button(game_win, text='Listening', command=lambda: [game_win.destroy(), self._start_listening_mode(selected_list.get())])
        listen_btn.pack(pady=5)

    def _start_quiz_mode(self, bird_list_name=None):
        game_df = self._get_game_df(bird_list_name)
        QuizMode(self.root, game_df)

    def _start_listening_mode(self, bird_list_name=None):
        game_df = self._get_game_df(bird_list_name)
        ListeningMode(self.root, game_df)

    def _get_game_df(self, bird_list_name):
        if bird_list_name and bird_list_name in self.bird_lists:
            birds = set(self.bird_lists[bird_list_name])
            return self.filtered_df[self.filtered_df['species'].isin(birds)]
        else:
            return self.filtered_df

    def _toggle_pause(self):
        if not pygame.mixer.music.get_busy():
            return
        if self.is_paused:
            pygame.mixer.music.unpause()
            self.pause_btn.config(text='Pause')
            self.is_paused = False
        else:
            pygame.mixer.music.pause()
            self.pause_btn.config(text='Resume')
            self.is_paused = True

    def _stop_playback(self):
        pygame.mixer.music.stop()
        if hasattr(self, 'pause_btn'):
            self.pause_btn.config(text='Pause')
        self.is_paused = False

    def _load_bird_lists(self):
        if os.path.exists(BIRD_LISTS_PATH):
            with open(BIRD_LISTS_PATH, 'r') as f:
                return json.load(f)
        else:
            return {}

    def _save_bird_lists(self):
        with open(BIRD_LISTS_PATH, 'w') as f:
            json.dump(self.bird_lists, f, indent=2)

    def _open_bird_list_manager(self):
        BirdListManager(self)

# --- Quiz Mode ---
class QuizMode:
    def __init__(self, parent, df):
        self.df = df.copy()
        self.window = tk.Toplevel(parent)
        self.window.title('Quiz Mode')
        self.window.geometry('400x320')
        self.auto_advance = tk.BooleanVar(value=True)
        self._build_ui()
        self._next_question()
        self.window.protocol('WM_DELETE_WINDOW', self._on_close)

    def _build_ui(self):
        self.prompt = ttk.Label(self.window, text='Listen to the sound and choose the bird:')
        self.prompt.pack(pady=10)
        self.play_btn = ttk.Button(self.window, text='Play Sound', command=self._play_sound)
        self.play_btn.pack(pady=5)
        self.options_frame = ttk.Frame(self.window)
        self.options_frame.pack(pady=10)
        self.feedback = ttk.Label(self.window, text='')
        self.feedback.pack(pady=5)
        self.next_btn = ttk.Button(self.window, text='Next', command=self._next_question, state='disabled')
        self.next_btn.pack(pady=5)
        auto_frame = ttk.Frame(self.window)
        auto_frame.pack(pady=2)
        auto_cb = ttk.Checkbutton(auto_frame, text='Auto-advance on correct', variable=self.auto_advance)
        auto_cb.pack()

    def _next_question(self):
        pygame.mixer.music.stop()
        self.feedback.config(text='')
        self.next_btn.config(state='disabled')
        self.options = []
        self.current = self.df.sample(1).iloc[0]
        correct_bird = self.current['species']
        # Get 3 random other birds
        birds = list(self.df['species'].unique())
        birds.remove(correct_bird)
        distractors = random.sample(birds, min(3, len(birds)))
        options = [correct_bird] + distractors
        random.shuffle(options)
        for widget in self.options_frame.winfo_children():
            widget.destroy()
        for opt in options:
            btn = ttk.Button(self.options_frame, text=opt, command=lambda o=opt: self._check_answer(o))
            btn.pack(fill='x', pady=2)
        self.options = options
        self.sound_played = False
        # Auto-play sound for each question
        self._play_sound()

    def _play_sound(self):
        file_path = os.path.join(BIRDSONG_BASE_DIR, self.current['species'], self.current['file_name'])
        try:
            pygame.mixer.music.stop()
            pygame.mixer.music.load(file_path)
            pygame.mixer.music.play()
            self.sound_played = True
        except Exception as e:
            messagebox.showerror('Error', f'Could not play file: {e}')

    def _check_answer(self, selected):
        if not self.sound_played:
            self.feedback.config(text='Please play the sound first.')
            return
        correct = selected == self.current['species']
        if correct:
            self.feedback.config(text='Correct!', foreground='green')
            self.next_btn.config(state='normal')
            if self.auto_advance.get():
                self.window.after(1000, self._next_question)
        else:
            self.feedback.config(text=f'Incorrect! It was {self.current["species"]}.', foreground='red')
            self.next_btn.config(state='normal')

    def _on_close(self):
        pygame.mixer.music.stop()
        self.window.destroy()

# --- Listening Mode ---
class ListeningMode:
    def __init__(self, parent, df):
        self.df = df.copy()
        self.window = tk.Toplevel(parent)
        self.window.title('Listening Mode')
        self.window.geometry('400x200')
        self.show_name_first = tk.BooleanVar(value=True)
        self._build_ui()
        self._reset_playlist()
        self.window.protocol('WM_DELETE_WINDOW', self._on_close)

    def _build_ui(self):
        control_frame = ttk.Frame(self.window)
        control_frame.pack(pady=10)
        ttk.Label(control_frame, text='Show bird name:').pack(side='left')
        before_btn = ttk.Radiobutton(control_frame, text='Before', variable=self.show_name_first, value=True)
        before_btn.pack(side='left')
        after_btn = ttk.Radiobutton(control_frame, text='After', variable=self.show_name_first, value=False)
        after_btn.pack(side='left')
        self.play_btn = ttk.Button(self.window, text='Play Next', command=self._play_next)
        self.play_btn.pack(pady=10)
        self.name_label = ttk.Label(self.window, text='', font=('Arial', 14, 'bold'))
        self.name_label.pack(pady=10)

    def _reset_playlist(self):
        self.playlist = self.df.sample(frac=1).reset_index(drop=True).to_dict('records')
        self.idx = 0
        self.name_label.config(text='')

    def _play_next(self):
        pygame.mixer.music.stop()
        if self.idx >= len(self.playlist):
            self.name_label.config(text='Done!')
            return
        entry = self.playlist[self.idx]
        bird_name = entry['species']
        file_path = os.path.join(BIRDSONG_BASE_DIR, bird_name, entry['file_name'])
        if self.show_name_first.get():
            self.name_label.config(text=bird_name)
            self.window.after(500, lambda: self._play_audio(file_path))
        else:
            self.name_label.config(text='')
            self._play_audio(file_path, after_name=bird_name)
        self.idx += 1

    def _play_audio(self, file_path, after_name=None):
        try:
            pygame.mixer.music.stop()
            pygame.mixer.music.load(file_path)
            pygame.mixer.music.play()
            if after_name:
                self.window.after(1500, lambda: self.name_label.config(text=after_name))
        except Exception as e:
            messagebox.showerror('Error', f'Could not play file: {e}')

    def _on_close(self):
        pygame.mixer.music.stop()
        self.window.destroy()

class BirdListManager:
    def __init__(self, app):
        self.app = app
        self.df = app.df
        self.bird_lists = app.bird_lists
        self.window = tk.Toplevel(app.root)
        self.window.title('Manage Bird Lists')
        self.window.geometry('500x400')
        self.selected_list = tk.StringVar()
        self._build_ui()
        self._populate_lists()

    def _build_ui(self):
        top_frame = ttk.Frame(self.window)
        top_frame.pack(fill='x', pady=5)
        ttk.Label(top_frame, text='Bird Lists:').pack(side='left')
        self.list_combo = ttk.Combobox(top_frame, textvariable=self.selected_list, state='readonly')
        self.list_combo.pack(side='left', padx=5)
        self.list_combo.bind('<<ComboboxSelected>>', self._on_list_select)
        add_btn = ttk.Button(top_frame, text='New List', command=self._add_list)
        add_btn.pack(side='left', padx=5)
        rename_btn = ttk.Button(top_frame, text='Rename', command=self._rename_list)
        rename_btn.pack(side='left', padx=5)
        del_btn = ttk.Button(top_frame, text='Delete', command=self._delete_list)
        del_btn.pack(side='left', padx=5)
        self.bird_frame = ttk.Frame(self.window)
        self.bird_frame.pack(fill='both', expand=True, pady=10)
        self.bird_vars = {}

    def _populate_lists(self):
        lists = list(self.bird_lists.keys())
        self.list_combo['values'] = lists
        if lists:
            self.selected_list.set(lists[0])
            self._populate_bird_checkboxes(lists[0])
        else:
            self.selected_list.set('')
            self._populate_bird_checkboxes(None)

    def _on_list_select(self, event=None):
        list_name = self.selected_list.get()
        self._populate_bird_checkboxes(list_name)

    def _populate_bird_checkboxes(self, list_name):
        for widget in self.bird_frame.winfo_children():
            widget.destroy()
        self.bird_vars = {}
        birds = sorted(self.df['species'].unique())
        selected = set(self.bird_lists.get(list_name, [])) if list_name else set()
        for bird in birds:
            var = tk.BooleanVar(value=bird in selected)
            cb = ttk.Checkbutton(self.bird_frame, text=bird, variable=var, command=lambda b=bird, v=var: self._toggle_bird(b, v))
            cb.pack(anchor='w')
            self.bird_vars[bird] = var

    def _toggle_bird(self, bird, var):
        list_name = self.selected_list.get()
        if not list_name:
            return
        if var.get():
            if bird not in self.bird_lists[list_name]:
                self.bird_lists[list_name].append(bird)
        else:
            if bird in self.bird_lists[list_name]:
                self.bird_lists[list_name].remove(bird)
        self.app._save_bird_lists()

    def _add_list(self):
        name = simpledialog.askstring('New List', 'Enter a name for the new bird list:', parent=self.window)
        if name and name not in self.bird_lists:
            self.bird_lists[name] = []
            self.app._save_bird_lists()
            self._populate_lists()
            self.selected_list.set(name)
            self._populate_bird_checkboxes(name)

    def _rename_list(self):
        old = self.selected_list.get()
        if not old:
            return
        name = simpledialog.askstring('Rename List', 'Enter a new name:', initialvalue=old, parent=self.window)
        if name and name != old and name not in self.bird_lists:
            self.bird_lists[name] = self.bird_lists.pop(old)
            self.app._save_bird_lists()
            self._populate_lists()
            self.selected_list.set(name)
            self._populate_bird_checkboxes(name)

    def _delete_list(self):
        name = self.selected_list.get()
        if not name:
            return
        if messagebox.askyesno('Delete List', f'Delete bird list "{name}"?'):
            del self.bird_lists[name]
            self.app._save_bird_lists()
            self._populate_lists()

if __name__ == '__main__':
    root = tk.Tk()
    app = BirdsongTrainerApp(root)
    root.mainloop()
