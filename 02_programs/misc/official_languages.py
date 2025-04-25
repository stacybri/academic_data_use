import requests
import re
import pandas as pd
from bs4 import BeautifulSoup

# Make a request to the CIA World Factbook website
url = "https://www.cia.gov/the-world-factbook/field/languages/"
response = requests.get(url)
html_content = response.text

# Parse the HTML
soup = BeautifulSoup(html_content, 'html.parser')
country_sections = soup.find_all('div', class_='pb30')

# Lists to store the data
countries = []
languages = []
official_languages = []
",


# Regular expression to identify official languages
official_pattern = re.compile(r'\b(official)\b', re.IGNORECASE)

# Extract data from each country section
for i, section in enumerate(country_sections):
    # Get country name from the heading
    h3_element = section.find('h3', class_='mt10')
    
    # Skip if we can't find the h3 element
    if not h3_element:
        continue
        
    country_link = h3_element.find('a')
    
    # Skip if we can't find the link
    if not country_link:
        continue
        
    country_name = country_link.text.strip()
    
    # APPROACH: Get text from the HTML content directly
    # This is especially important for cases where the text is not in a specific tag
    
    # Convert the section to a string and use regex to extract content
    section_html = str(section)
    
    # Find the country heading in the HTML
    country_heading_pattern = f'<a href="[^"]+?">{re.escape(country_name)}</a></h3>'
    match = re.search(country_heading_pattern, section_html)
    
    language_text = "No data available"
    
    if match:
        # Extract everything after the heading until the next major tag
        end_of_heading = match.end()
        text_after_heading = section_html[end_of_heading:]
        
        # Find the first marker that signals the end of the language information
        end_markers = ['<strong>major-language sample', '<strong>note:', '<br><br>']
        end_positions = []
        
        for marker in end_markers:
            pos = text_after_heading.find(marker)
            if pos > 0:
                end_positions.append(pos)
        
        if end_positions:
            # Use the earliest marker
            end_pos = min(end_positions)
            language_html = text_after_heading[:end_pos]
            
            # Remove any remaining HTML tags
            language_text = BeautifulSoup(language_html, 'html.parser').get_text().strip()
        else:
            # If no markers found, try to extract until the first HTML tag
            match = re.search(r'</h3>(.*?)(?=<\w+|$)', section_html)
            if match:
                language_text = match.group(1).strip()
                # Clean up any HTML entities
                language_text = BeautifulSoup(language_text, 'html.parser').get_text().strip()
    
    # Only use "No data available" if we actually found nothing
    if not language_text or language_text == "No data available":
        # One last attempt - check for text nodes that are direct children of the section
        # after the h3 element but before any br tag
        possible_text = ""
        for node in h3_element.next_siblings:
            if isinstance(node, str) and node.strip():
                possible_text += node.strip() + " "
            elif node.name == 'br':
                break
        
        if possible_text:
            language_text = possible_text.strip()
    
    # Extract official languages
    official_langs = []
    if official_pattern.search(language_text):
        # Various patterns to match official languages
        for match in re.finditer(r'([A-Za-z\s\-]+)\s*\(official(?:[^)]*)\)', language_text):
            official_langs.append(match.group(1).strip())
        for match in re.finditer(r'([A-Za-z\s\-]+)\s*\(official\)', language_text):
            official_langs.append(match.group(1).strip())
        for match in re.finditer(r'([A-Za-z\s\-,]+)\s*\((?:all|both)\s+official\)', language_text):
            langs = [l.strip() for l in match.group(1).split(',')]
            official_langs.extend(langs)
        for match in re.finditer(r'([A-Za-z\s\-]+)\s+official\b', language_text):
            official_langs.append(match.group(1).strip())
    
    # Add to our lists
    countries.append(country_name)
    languages.append(language_text)
    official_languages.append(', '.join(official_langs) if official_langs else "")

# Create DataFrame
df = pd.DataFrame({
    'Country': countries,
    'Languages': languages,
    'Official_Languages': official_languages
})

# Clean up the data
df['Languages'] = df['Languages'].apply(lambda x: re.sub(r'\s+', ' ', x).strip())

# Save to CSV
df.to_csv('world_languages.csv', index=False)

# Show the first few rows
print(df.head())