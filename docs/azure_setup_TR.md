# Azure Kurulum Akışı

Bu belge, Azure üzerinde kurulan honeypot ortamının ilk kurulum akışını dokümante eder. Buradaki adımlar, Windows sanal makinesinin hazırlanması, Log Analytics ve Microsoft Sentinel bağlantılarının yapılması, veri toplama kuralı (DCR) oluşturulması ve özel `failed_rdp.log` akışının sisteme eklenmesini kapsar.

> **Not:** Proje daha sonra Azure Sentinel merkezli bir dashboard çalışmasından, GitHub üzerinde açık kaynak bir tehdit istihbaratı veri seti projesine evrildi. Yine de bu kurulum adımları, veri toplama boru hattının nasıl oluştuğunu gösterdiği için korunuyor.

---

## 1. Honeypot VM Oluşturma

Windows tabanlı, dış ağa açık bir Azure sanal makinesi oluşturuldu. Bu makine kasıtlı olarak RDP brute-force denemelerini çekmek için kullanıldı.

### 1.1 Genel Ayarlar Özeti

![VM oluşturma — temel ayarlar](./Screenshots/01-vm-create-review-basics.png)

### 1.2 Ağ ve NIC Ayarları

![VM oluşturma — ağ ayarları](./Screenshots/02-vm-create-review-networking.png)

### 1.3 İzleme ve Gelişmiş Ayarlar

![VM oluşturma — izleme ayarları](./Screenshots/03-vm-create-review-monitoring.png)

---

## 2. Log Analytics Workspace Oluşturma

Azure loglarını toplamak için önce bir Log Analytics workspace oluşturuldu. Bu workspace, hem güvenlik olaylarının hem de özel log dosyalarının merkezi depolama noktası olarak görev yapar.

### 2.1 Boş Durum

![Log Analytics — boş durum](./Screenshots/04-log-analytics-empty-state.png)

### 2.2 Workspace Formu

![Log Analytics — oluşturma formu](./Screenshots/05-log-analytics-create-form.png)

### 2.3 Gözden Geçir ve Oluştur

![Log Analytics — gözden geçir ve oluştur](./Screenshots/06-log-analytics-review-create.png)

---

## 3. Microsoft Sentinel Etkinleştirme

Workspace oluşturulduktan sonra Microsoft Sentinel aynı workspace üzerine bağlandı. Sentinel, güvenlik olaylarını görselleştirmek ve analiz etmek için kullanılan SIEM katmanıdır.

### 3.1 Sentinel Boş Durum

![Sentinel — boş durum](./Screenshots/07-sentinel-empty-state.png)

### 3.2 Sentinel Genel Bakış

![Sentinel — genel bakış](./Screenshots/08-sentinel-overview.png)

---

## 4. Windows Security Events İçin DCR Oluşturma

Bu aşamada, Event ID 4625 gibi güvenlik olaylarını toplamak amacıyla Azure Monitor Agent (AMA) tabanlı bir veri toplama kuralı (Data Collection Rule — DCR) tanımlandı.

### 4.1 DCR Temel Ayarları

![DCR — temel ayarlar](./Screenshots/09-dcr-create-basic.png)

### 4.2 Hedef Sanal Makineyi Seçme

![DCR — VM seçimi](./Screenshots/10-dcr-select-vm.png)

### 4.3 Gözden Geçirme ve Oluşturma

![DCR — gözden geçir ve oluştur](./Screenshots/11-dcr-review-create.png)

---

## 5. Honeypot Davranışını Sertleştirmek Yerine Açık Bırakma

Bu proje bir honeypot olduğu için, bağlantı yüzeyini daha görünür hale getirmek amacıyla Windows Firewall kapatıldı. Bu ayar **yalnızca kontrollü lab ortamı** için uygundur ve üretim sistemlerinde kesinlikle yapılmamalıdır.

### 5.1 Firewall Kapatma

![Windows Firewall kapatma](./Screenshots/12-disable-windows-firewall.png)

### 5.2 Genel IP Erişilebilirliğini Doğrulama

![Genel IP doğrulama — ping testi](./Screenshots/13-verify-public-ip-ping.png)

---

## 6. Özel Log Akışının Tasarlanması

PowerShell betiği tarafından üretilen `failed_rdp.log` dosyası, Azure tarafına özel metin günlüğü (Custom Text Log) olarak bağlandı. Bu sayede betik tarafından toplanan coğrafi konum verisi de Azure'a aktarılabilir hale geldi.

### 6.1 Özel Günlük Oluşturma Özet Ekranı

![Özel günlük — gözden geçir ve oluştur](./Screenshots/14-custom-log-review-create.png)

### 6.2 DCR Kaynak İlişkisi (İlk Durum)

![DCR — ilişkili kaynaklar (başlangıç)](./Screenshots/15-dcr-associated-resources-initial.png)

### 6.3 Log Dosyasının Sistemdeki Konumu

![ProgramData — failed_rdp.log konumu](./Screenshots/16-programdata-failed-rdp-log.png)

### 6.4 Özel Metin Günlüğü Veri Kaynağı

![Özel metin günlüğü kaynağı ekleme](./Screenshots/17-add-custom-text-log-source.png)

### 6.5 Hedef Workspace Seçimi

![Özel günlük — hedef workspace](./Screenshots/18-add-custom-log-destination.png)

### 6.6 Veri Kaynağını DCR İçine Ekleme

![DCR — veri kaynağı ekleme](./Screenshots/19-add-data-source-to-dcr.png)

### 6.7 DCR Kaynaklarının Doğrulanması

![DCR — ilişkili kaynaklar (onaylanmış)](./Screenshots/20-dcr-associated-resources-confirmed.png)

---

## 7. Toplanan Veriyi Doğrulama

Kurulum sonrasında, hem Azure tarafında hem de VM içinde log akışı test edildi. Sentinel üzerinden Event ID 4625 sorgusu yapılarak başarısız RDP girişlerinin doğru şekilde toplandığı teyit edildi.

### 7.1 Sentinel Üzerinde Event ID 4625 Sorgusu

![Sentinel — SecurityEvent 4625 sorgusu](./Screenshots/21-sentinel-securityevent-4625-query.png)

### 7.2 PowerShell Logger Canlı Çıktı

![PowerShell logger — canlı çıktı](./Screenshots/22-powershell-logger-live-output.png)

---

## 8. Bugünkü Proje Yönü

Azure Sentinel üzerinden klasik SIEM görselleştirmesi yapmak yerine, sistemin aşağıdaki çıktıya odaklanması daha değerli bulundu:

- 📊 Başarısız RDP girişlerinden oluşan ham tehdit verisi
- 🌍 IP bazlı geolocation ile zenginleştirilmiş loglar
- 🔁 Brute-force frekansını koruyan, tekrar kayıtları engelleyen temiz dataset
- 🌐 GitHub üzerinden paylaşılabilecek açık kaynak siber güvenlik veri seti

> Bu mimari, hafif ve taşınabilir bir tehdit istihbaratı toplayıcısı olarak tasarlandı. Azure Sentinel'in sunduğu ağır altyapıya ihtiyaç duymadan, PowerShell ve yerel Windows araçlarıyla aynı işi çok daha verimli şekilde yapar.
