<div align="center">
  <a href="#english"> English</a> |
  <a href="#türkçe"> Türkçe</a>
</div>

<a id="english"></a>

# 🛡️ Azure RDP Honeypot & Threat Intelligence Dataset

A highly optimized, out-of-the-box Windows Honeypot architecture and a 1-day sample dataset of global RDP brute-force attacks. 

This project demonstrates how to turn a vulnerable Azure Virtual Machine into an autonomous Threat Intelligence collector using native Windows tools and PowerShell.

## 🚀 The Vision & Architecture
Instead of relying on heavy and complex SIEM forwarders (like Azure Sentinel) for basic honeypot logging, this project utilizes a custom, lightweight PowerShell script. 

**How it works:**
1. A Windows VM is exposed to the internet on Azure.
2. The custom PowerShell script listens to `Event ID 4625` (Failed RDP Logins) in real-time.
3. The script extracts the attacker's IP and queries the `ipgeolocation.io` API.
4. Data is mapped and formatted into a clean dataset ready for Machine Learning / Data Analysis.

### 💡 Engineering Highlights
* **In-Memory IP Caching:** To preserve API rate limits, the script caches attacker IPs in RAM. If the same IP attacks 1,000 times, the API is only queried *once*.
* **RecordID Tracking:** Prevents log duplication by tracking the Windows Event `RecordID`. It logs every single attack frequency accurately without writing duplicates to the dataset.

## 📂 Repository Structure
* `/scripts/Honeypot_Logger.ps1` - The optimized PowerShell autonomous agent.
* `/logs/failed_rdp.log` - A 1-day real-world snapshot of brute-force attacks (raw format).
* `/docs/` - Screenshots and guides on how the Azure environment was configured.

> 🔒 **Privacy & Security Notice:** All IP addresses in the `.log` file have been **partially masked** (e.g. `x.x.0.0`) to prevent the exposure of real attacker IPs in a public repository. Screenshots in the `/docs/` directory have also been **redacted** for the same reason. The geographic metadata (country, state, coordinates) is preserved for analysis purposes, but the original source IPs are anonymized.

## 🛠️ How to Build Your Own
1. Create a free-tier Windows VM on Azure and open port 3389 to the public.
2. Clone this repository to your VM.
3. Get a free API key from [ipgeolocation.io](https://ipgeolocation.io/).
4. Edit the `Honeypot_Logger.ps1` file and replace `<YOUR_API_KEY_HERE>` with your key.
5. Run the script as Administrator and watch the attacks roll in!


<br>

---

<br>

<a id="türkçe"></a>

# 🛡️ Azure RDP Honeypot & Tehdit İstihbaratı Veri Seti

Küresel RDP kaba kuvvet (brute-force) saldırılarının 1 günlük örnek veri setini içeren, baştan sona optimize edilmiş, kullanıma hazır bir Windows Honeypot mimarisi.

Bu proje, savunmasız bir Azure Sanal Makinesinin (VM) yerel Windows araçları ve PowerShell kullanılarak otonom bir Tehdit İstihbaratı toplayıcısına nasıl dönüştürüleceğini göstermektedir.

## 🚀 Vizyon ve Mimari
Bu proje, temel honeypot loglaması için ağır ve karmaşık SIEM yönlendiricilerine (Azure Sentinel gibi) güvenmek yerine, hafif ve özel bir PowerShell betiği kullanmaktadır.

**Nasıl çalışır:**
1. Azure üzerinde bir Windows VM oluşturulur ve internete açılır.
2. Özel PowerShell betiği, gerçek zamanlı olarak `Olay Kimliği 4625`'i (Başarısız RDP Girişleri) dinler.
3. Betik, saldırganın IP adresini çıkar ve `ipgeolocation.io` API'sini sorgular.
4. Veriler eşlenir ve Makine Öğrenimi / Veri Analizi için hazır, temiz bir veri seti formatına dönüştürülür.

### 💡 Öne Çıkan Mühendislik Özellikleri
* **Bellek İçi IP Ön Bellekleme (In-Memory IP Caching):** API hız sınırlarını aşmamak için betik, saldırgan IP'lerini RAM'de ön belleğe alır. Aynı IP 1.000 kez saldırsa bile, API yalnızca *bir kez* sorgulanır.
* **RecordID Takibi:** Windows Event `RecordID` izlenerek log (kayıt) kopyalarının önüne geçilir. Veri setine kopya yazmadan her bir saldırı sıklığını doğru bir şekilde kaydeder.

## 📂 Depo Yapısı
* `/scripts/Honeypot_Logger.ps1` - Optimize edilmiş PowerShell otonom ajanı.
* `/logs/failed_rdp.log` - Gerçek dünyadan, kaba kuvvet saldırılarının 1 günlük anlık görüntüsü (ham format).
* `/docs/` - Azure ortamının nasıl yapılandırıldığına dair ekran görüntüleri ve kılavuzlar.

> 🔒 **Gizlilik ve Güvenlik Bildirimi:** `.log` dosyasındaki tüm IP adresleri, gerçek saldırgan IP'lerinin herkese açık bir depoda ifşa edilmesini önlemek amacıyla **kısmen maskelenmiştir** (örn. `x.x.0.0`). `/docs/` klasöründeki ekran görüntülerindeki IP adresleri de aynı gerekçeyle **sansürlenmiştir**. Coğrafi meta veriler (ülke, eyalet, koordinatlar) analiz amacıyla korunmuştur, ancak kaynak IP adresleri anonimleştirilmiştir.

## 🛠️ Kendiniz Nasıl Kurabilirsiniz?
1. Azure üzerinde ücretsiz seviyede bir Windows VM oluşturun ve 3389 numaralı portu herkese açık olacak şekilde açın.
2. Bu depoyu sanal makinenize klonlayın.
3. [ipgeolocation.io](https://ipgeolocation.io/) adresinden ücretsiz bir API anahtarı alın.
4. `Honeypot_Logger.ps1` dosyasını düzenleyin ve `<YOUR_API_KEY_HERE>` kısmını kendi anahtarınızla değiştirin.
5. Betiği Yönetici (Administrator) olarak çalıştırın ve gelen saldırıları izleyin!