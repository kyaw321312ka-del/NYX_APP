class ContactUsData {
  final String? logoImageUrl;
  final String? shopName;
  final String? contactInfo;
  final String? address;
  final String? socialLink;

  ContactUsData({
    this.logoImageUrl,
    this.shopName,
    this.contactInfo,
    this.address,
    this.socialLink,
  });

  factory ContactUsData.fromJson(Map<String, dynamic> json) {
    return ContactUsData(
      logoImageUrl: json['logo_image_url']?.toString(),
      shopName: json['shop_name']?.toString(),
      contactInfo: json['contact_info']?.toString(),
      address: json['address']?.toString(),
      socialLink: json['social_link']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'logo_image_url': logoImageUrl,
      'shop_name': shopName,
      'contact_info': contactInfo,
      'address': address,
      'social_link': socialLink,
    };
  }
}