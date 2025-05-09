import os
import re
import requests
from bs4 import BeautifulSoup
import pandas as pd
from scientific_names import SCIENTIFIC_NAMES
import time
from mutagen.mp3 import MP3

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

def download_mp3s(links_and_types, folder, delay=1, retries=3):
    os.makedirs(folder, exist_ok=True)
    success_count = 0
    fail_count = 0
    for link, _ in links_and_types:
        filename = os.path.join(folder, link.split('/')[-1])
        if os.path.exists(filename):
            continue  # Skip existing files
        for attempt in range(retries):
            try:
                with requests.get(link, stream=True, timeout=10) as r:
                    if r.status_code == 200:
                        with open(filename, 'wb') as f:
                            for chunk in r.iter_content(chunk_size=8192):
                                f.write(chunk)
                        # Optionally check file size or integrity here
                        success_count += 1
                        break
                    else:
                        print(f'Failed to download {link}: status {r.status_code}')
            except Exception as e:
                print(f'Error downloading {link}: {e}')
            if attempt < retries - 1:
                time.sleep(delay)
        else:
            print(f'Failed to download {link} after {retries} attempts')
            fail_count += 1
        time.sleep(delay)
    return success_count, fail_count

def sync_birdsong(delay=1, retries=3):
    with open(WARBLER_LIST_PATH) as f:
        birds = [line.strip() for line in f if line.strip()]
    total_success = 0
    total_fail = 0
    total_attempted = 0
    for bird in birds:
        bird_url_name = bird.replace("'", "").replace(" ", "_")
        url = f"https://www.allaboutbirds.org/guide/{bird_url_name}/sounds"
        print(f"Scraping {url}")
        mp3_links_and_types = get_mp3_links_and_types(url)
        folder = os.path.join(BIRDSONG_BASE_DIR, bird)
        attempted = len([link for link, _ in mp3_links_and_types if not os.path.exists(os.path.join(folder, link.split('/')[-1]))])
        success, fail = download_mp3s(mp3_links_and_types, folder, delay=delay, retries=retries)
        total_success += success
        total_fail += fail
        total_attempted += attempted
        print(f"{bird}: Attempted {attempted}, Downloaded {success}, Failed {fail}")
    print(f"\nSummary: Attempted {total_attempted}, Downloaded {total_success}, Failed {total_fail}")

def cleanup_birdsong(base_dir):
    print('Scanning for corrupted or unplayable files...')
    for root, dirs, files in os.walk(base_dir):
        for file in files:
            if file.endswith('.mp3'):
                path = os.path.join(root, file)
                try:
                    audio = MP3(path)
                    if audio.info.length < 1:  # Too short, likely bad
                        print(f'Deleting short file: {path}')
                        os.remove(path)
                except Exception as e:
                    print(f'Deleting corrupted file: {path} ({e})')
                    os.remove(path)
    print('Cleanup complete.')

def create_birdsong_excel():
    rows = []
    with open(WARBLER_LIST_PATH) as f:
        birds = [line.strip() for line in f if line.strip()]
    for bird in birds:
        folder = os.path.join(BIRDSONG_BASE_DIR, bird)
        if not os.path.isdir(folder):
            continue
        # Optionally, re-scrape the page to get the type for each file
        bird_url_name = bird.replace("'", "").replace(" ", "_")
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
    while True:
        print("\nBirdsong Scraper Menu:")
        print("1. Sync/download bird songs (with delay and retry)")
        print("2. Clean up corrupted/unplayable files")
        print("3. Regenerate Excel database")
        print("4. Exit")
        choice = input("Enter your choice (1-4): ").strip()
        if choice == '1':
            delay = input("Enter delay between downloads in seconds (default 1): ").strip()
            delay = float(delay) if delay else 1
            retries = input("Enter number of retries per file (default 3): ").strip()
            retries = int(retries) if retries else 3
            sync_birdsong(delay=delay, retries=retries)
        elif choice == '2':
            cleanup_birdsong(BIRDSONG_BASE_DIR)
        elif choice == '3':
            create_birdsong_excel()
        elif choice == '4':
            print("Exiting.")
            break
        else:
            print("Invalid choice. Please enter 1, 2, 3, or 4.")
