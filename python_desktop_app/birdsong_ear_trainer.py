import os
import pandas as pd
import tkinter as tk
from tkinter import ttk, messagebox
import pygame

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
BIRDSONG_BASE_DIR = os.path.join(SCRIPT_DIR, '..', 'birdsong')
EXCEL_PATH = os.path.join(BIRDSONG_BASE_DIR, 'birdsong_database.xlsx')

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

    def _init_audio(self):
        pygame.mixer.init()

    def _build_gui(self):
        # Sound type filter
        filter_frame = ttk.Frame(self.root)
        filter_frame.pack(fill='x', padx=10, pady=5)
        ttk.Label(filter_frame, text='Filter by Sound Type:').pack(side='left')
        self.sound_type_var = tk.StringVar()
        self.sound_type_combo = ttk.Combobox(filter_frame, textvariable=self.sound_type_var, state='readonly')
        self.sound_type_combo.pack(side='left', padx=5)
        self.sound_type_combo.bind('<<ComboboxSelected>>', self._on_filter_change)
        # Bird list
        bird_frame = ttk.Frame(self.root)
        bird_frame.pack(side='left', fill='y', padx=10, pady=5)
        ttk.Label(bird_frame, text='Birds').pack()
        self.bird_listbox = tk.Listbox(bird_frame, width=30)
        self.bird_listbox.pack(fill='y', expand=True)
        self.bird_listbox.bind('<<ListboxSelect>>', self._on_bird_select)
        # Sound file list
        sound_frame = ttk.Frame(self.root)
        sound_frame.pack(side='left', fill='both', expand=True, padx=10, pady=5)
        ttk.Label(sound_frame, text='Sound Files').pack()
        self.sound_listbox = tk.Listbox(sound_frame, width=50)
        self.sound_listbox.pack(fill='both', expand=True)
        self.sound_listbox.bind('<<ListboxSelect>>', self._on_sound_select)
        # Play button
        self.play_button = ttk.Button(sound_frame, text='Play', command=self._play_selected)
        self.play_button.pack(pady=10)

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
        self.sound_listbox.delete(0, tk.END)
        self.selected_bird = None
        self.selected_file = None

    def _on_filter_change(self, event=None):
        selected_type = self.sound_type_var.get()
        if selected_type == 'All':
            self.filtered_df = self.df.copy()
        elif selected_type.lower() in ['song', 'calls', 'tink calls', 'flight calls', 'chip calls']:
            keyword = selected_type.lower().replace(' ', '')[:-1] if selected_type.lower().endswith('s') else selected_type.lower().replace(' ', '')
            # Match any sound_type containing the umbrella keyword (case-insensitive, ignore spaces and plural)
            self.filtered_df = self.df[self.df['sound_type'].str.lower().str.replace(' ', '').str.contains(keyword)]
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
        self.sound_listbox.delete(0, tk.END)
        files = self.filtered_df[self.filtered_df['species'] == bird]['file_name'].tolist()
        for f in files:
            self.sound_listbox.insert(tk.END, f)
        self.selected_file = None

    def _on_sound_select(self, event=None):
        selection = self.sound_listbox.curselection()
        if not selection:
            return
        self.selected_file = self.sound_listbox.get(selection[0])

    def _play_selected(self):
        if not self.selected_bird or not self.selected_file:
            messagebox.showinfo('Info', 'Please select a bird and a sound file.')
            return
        file_path = os.path.join(BIRDSONG_BASE_DIR, self.selected_bird, self.selected_file)
        if not os.path.exists(file_path):
            messagebox.showerror('Error', f'File not found: {file_path}')
            return
        try:
            pygame.mixer.music.load(file_path)
            pygame.mixer.music.play()
        except Exception as e:
            messagebox.showerror('Error', f'Could not play file: {e}')

if __name__ == '__main__':
    root = tk.Tk()
    app = BirdsongTrainerApp(root)
    root.mainloop()
