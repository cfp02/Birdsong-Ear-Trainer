import os
import re
import requests
from bs4 import BeautifulSoup
import pandas as pd
from scientific_names import SCIENTIFIC_NAMES

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
WARBLER_LIST_PATH = os.path.join(SCRIPT_DIR, 'warbler_list.txt')
BIRDSONG_BASE_DIR = os.path.join(SCRIPT_DIR, '..', 'birdsong')
EXCEL_PATH = os.path.join(BIRDSONG_BASE_DIR, 'birdsong_database.xlsx')

def format_bird_name(name):
    return name.replace("'", "").replace(" ", "_")

def get_mp3_links_and_types(url):
    response = requests.get(url)
    soup = BeautifulSoup(response.text, 'html.parser')
    results = []
    for li in soup.find_all('li'):
        div_audio = li.find('div', class_='jp-jplayer player-audio')
        if not div_audio:
            continue
        # Get mp3 link
        mp3_url = div_audio.get('name')
        if not mp3_url or not mp3_url.endswith('.mp3'):
            continue
        # Get type from aria-label or span
        div_flat = li.find('div', class_='jp-flat-audio')
        audio_type = ''
        if div_flat:
            audio_type = div_flat.get('aria-label', '')
            if not audio_type:
                span_title = div_flat.find('span', class_='jp-title')
                if span_title:
                    audio_type = span_title.text.strip()
        results.append((mp3_url, audio_type))
    return results

def download_mp3s(links_and_types, folder):
    os.makedirs(folder, exist_ok=True)
    for link, _ in links_and_types:
        filename = os.path.join(folder, link.split('/')[-1])
        if os.path.exists(filename):
            continue  # Skip existing files
        with requests.get(link, stream=True) as r:
            with open(filename, 'wb') as f:
                for chunk in r.iter_content(chunk_size=8192):
                    f.write(chunk)

def sync_birdsong():
    with open(WARBLER_LIST_PATH) as f:
        birds = [line.strip() for line in f if line.strip()]
    for bird in birds:
        bird_url_name = format_bird_name(bird)
        url = f"https://www.allaboutbirds.org/guide/{bird_url_name}/sounds"
        print(f"Scraping {url}")
        mp3_links_and_types = get_mp3_links_and_types(url)
        folder = os.path.join(BIRDSONG_BASE_DIR, bird)
        download_mp3s(mp3_links_and_types, folder)

def create_birdsong_excel():
    rows = []
    with open(WARBLER_LIST_PATH) as f:
        birds = [line.strip() for line in f if line.strip()]
    for bird in birds:
        folder = os.path.join(BIRDSONG_BASE_DIR, bird)
        if not os.path.isdir(folder):
            continue
        # Optionally, re-scrape the page to get the type for each file
        bird_url_name = format_bird_name(bird)
        url = f"https://www.allaboutbirds.org/guide/{bird_url_name}/sounds"
        mp3_links_and_types = get_mp3_links_and_types(url)
        type_dict = {link.split('/')[-1]: audio_type for link, audio_type in mp3_links_and_types}
        for file in os.listdir(folder):
            if file.endswith('.mp3'):
                scientific = SCIENTIFIC_NAMES.get(bird, '')
                sound_type = type_dict.get(file, '')
                rows.append({
                    'file_name': file,
                    'species': bird,
                    'scientific_name': scientific,
                    'sound_type': sound_type,
                })
    df = pd.DataFrame(rows, columns=['file_name', 'species', 'scientific_name', 'sound_type'])
    df.to_excel(EXCEL_PATH, index=False)
    print(f"Excel database created at {EXCEL_PATH}")

if __name__ == '__main__':
    # sync_birdsong()  # re-download all mp3s
    create_birdsong_excel()
