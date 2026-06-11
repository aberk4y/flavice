import os
import requests

PEXELS_API_KEY = "TI1snjMEEnIDQCPE6vQ3FaEl4Ru8hnjIZk96NnT8vpg9wWgYXHKLJpMV"

headers = {
"Authorization": PEXELS_API_KEY
}

categories = {
"corbalar": "soup food",
"anayemekler": "turkish main dish",
"tatlilar": "dessert food",
"kahvaltiliklar": "breakfast food",
"salatalar": "fresh salad",
"icecekler": "drink beverage",
"atistirmaliklar": "snack food",
"hamurisleri": "bakery pastry"
}

recipes = {
    # Çorbalar
    "mercimek_corbasi": "lentil soup",
    "ezogelin": "turkish soup",
    "domates_corbasi": "tomato soup",
    "tarhana": "soup",
    "yayla_corbasi": "yogurt soup",

    # Ana Yemekler
    "karniyarik": "eggplant dish",
    "manti": "dumplings",
    "izmir_kofte": "meatballs",
    "tavuk_sote": "chicken dish",
    "et_sote": "beef dish",

    # Tatlılar
    "sutlac": "rice pudding",
    "tiramisu": "tiramisu",
    "cheesecake": "cheesecake",
    "brownie": "brownie",
    "profiterol": "dessert",

    # Kahvaltı
    "menemen": "scrambled eggs tomato",
    "pankek": "pancakes",
    "omlet": "omelette",
    "french_toast": "french toast",
    "toast": "toast breakfast",

    # Salatalar
    "coban_salata": "salad",
    "sezar_salata": "caesar salad",
    "akdeniz_salata": "mediterranean salad",
    "kisir": "bulgur salad",
    "patates_salata": "potato salad",

    # İçecekler
    "limonata": "lemonade",
    "ayran": "yogurt drink",
    "turk_kahvesi": "coffee",
    "milkshake": "milkshake",
    "smoothie": "smoothie",

    # Atıştırmalıklar
    "patates_kizartmasi": "french fries",
    "nachos": "nachos",
    "popcorn": "popcorn",
    "mini_pizza": "pizza",
    "sandvic": "sandwich",

    # Hamur İşleri
    "pogaca": "pastry",
    "acma": "bakery bread",
    "su_boregi": "pastry",
    "pizza": "pizza",
    "lahmacun": "flatbread"
}

os.makedirs("assets/images/categories", exist_ok=True)
os.makedirs("assets/images/recipes", exist_ok=True)

def download_image(search_query, output_path):
    url = f"https://api.pexels.com/v1/search?query={search_query}&per_page=1"

    response = requests.get(url, headers=headers)

    if response.status_code != 200:
      print(
        f"Hata {response.status_code}: {search_query}"
     )
      print(response.text)
      return

    data = response.json()

    if not data["photos"]:
     print("Bulunamadı:", search_query)
     return

    image_url = data["photos"][0]["src"]["large"]

    img = requests.get(image_url)

    with open(output_path, "wb") as f:
      f.write(img.content)

    print("İndirildi:", output_path)

for name, query in categories.items():
      download_image(
         query,
         f"assets/images/categories/{name}.jpg"
    )

for name, query in recipes.items():
    download_image(
        query,
        f"assets/images/recipes/{name}.jpg"
    )

print("Tüm görseller indirildi.")