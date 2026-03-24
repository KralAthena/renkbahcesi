module Colors
  COLOR_DEFS = [
    {
      id: :kirmizi,
      ad: "Kırmızı",
      hex: "#FF5252",
      kategori_etiketi: "temel",
      ses_adi: :kirmizi,
      aktif_mi: true,
      nesne_adi: "Elma",
      object_key: :apple,
      family_id: :kirmizi
    },
    {
      id: :mavi,
      ad: "Mavi",
      hex: "#40C4FF",
      kategori_etiketi: "temel",
      ses_adi: :mavi,
      aktif_mi: true,
      nesne_adi: "Damla",
      object_key: :droplet,
      family_id: :mavi
    },
    {
      id: :sari,
      ad: "Sarı",
      hex: "#FFEB3B",
      kategori_etiketi: "temel",
      ses_adi: :sari,
      aktif_mi: true,
      nesne_adi: "Muz",
      object_key: :banana,
      family_id: :sari
    },
    {
      id: :yesil,
      ad: "Yeşil",
      hex: "#69F0AE",
      kategori_etiketi: "temel",
      ses_adi: :yesil,
      aktif_mi: true,
      nesne_adi: "Yaprak",
      object_key: :leaf,
      family_id: :yesil
    },
    {
      id: :turuncu,
      ad: "Turuncu",
      hex: "#FFAB40",
      kategori_etiketi: "temel",
      ses_adi: :turuncu,
      aktif_mi: true,
      nesne_adi: "Havuç",
      object_key: :carrot,
      family_id: :turuncu
    },
    {
      id: :mor,
      ad: "Mor",
      hex: "#E040FB",
      kategori_etiketi: "temel",
      ses_adi: :mor,
      aktif_mi: true,
      nesne_adi: "Üzüm",
      object_key: :grape,
      family_id: :mor
    },
    {
      id: :pembe,
      ad: "Pembe",
      hex: "#FF4081",
      kategori_etiketi: "temel",
      ses_adi: :pembe,
      aktif_mi: true,
      nesne_adi: "Balon",
      object_key: :balloon,
      family_id: :pembe
    },
    {
      id: :kahverengi,
      ad: "Kahverengi",
      hex: "#967468",
      kategori_etiketi: "temel",
      ses_adi: :kahverengi,
      aktif_mi: true,
      nesne_adi: "Kozalak",
      object_key: :pinecone,
      family_id: :kahverengi
    },
    {
      id: :siyah,
      ad: "Siyah",
      hex: "#303030",
      kategori_etiketi: "temel",
      ses_adi: :siyah,
      aktif_mi: true,
      nesne_adi: "Taş",
      object_key: :stone,
      family_id: :siyah
    },
    {
      id: :beyaz,
      ad: "Beyaz",
      hex: "#FFFFFF",
      kategori_etiketi: "temel",
      ses_adi: :beyaz,
      aktif_mi: true,
      nesne_adi: "Bulut",
      object_key: :cloud,
      family_id: :beyaz
    },
    {
      id: :gri,
      ad: "Gri",
      hex: "#9E9E9E",
      kategori_etiketi: "ek",
      ses_adi: :gri,
      aktif_mi: false,
      nesne_adi: "Kaya",
      object_key: :rock,
      family_id: :gri
    },
    {
      id: :lacivert,
      ad: "Lacivert",
      hex: "#1A237E",
      kategori_etiketi: "ek",
      ses_adi: :lacivert,
      aktif_mi: false,
      nesne_adi: "Deniz",
      object_key: :sea,
      family_id: :lacivert
    },
    {
      id: :acik_mavi,
      ad: "Açık Mavi",
      hex: "#03A9F4",
      kategori_etiketi: "ek",
      ses_adi: :acik_mavi,
      aktif_mi: false,
      nesne_adi: "Balina",
      object_key: :whale,
      family_id: :acik_mavi
    },
    {
      id: :acik_yesil,
      ad: "Açık Yeşil",
      hex: "#66BB6A",
      kategori_etiketi: "ek",
      ses_adi: :acik_yesil,
      aktif_mi: false,
      nesne_adi: "Çim",
      object_key: :grass,
      family_id: :acik_yesil
    },
    {
      id: :bordo,
      ad: "Bordo",
      hex: "#5E0030",
      kategori_etiketi: "ek",
      ses_adi: :bordo,
      aktif_mi: false,
      nesne_adi: "Çiçek",
      object_key: :flower,
      family_id: :bordo
    }
  ].freeze

  def self.active_colors
    COLOR_DEFS.select { |c| c[:aktif_mi] }
  end

  def self.color_def(color_id)
    COLOR_DEFS.find { |c| c[:id] == color_id }
  end

  def self.all_color_defs
    COLOR_DEFS.dup
  end
end

