// ══ PembayaranInfo (inline) ════════════════════════════════════
class PembayaranInfo {
  final String status;
  final String? paymentUrl;
  final String? expiredAt;
 
  const PembayaranInfo({required this.status, this.paymentUrl, this.expiredAt});
 
  factory PembayaranInfo.fromJson(Map<String, dynamic> j) => PembayaranInfo(
    status: j['status'] ?? 'pending',
    paymentUrl: j['payment_url'],
    expiredAt: j['expired_at'],
  );
}