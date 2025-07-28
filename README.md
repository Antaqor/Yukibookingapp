# Юки захиалгын апп

Энэ төсөл нь Firebase Нэвтрэлт болон Realtime Database ашигласан SwiftUI-ийн демо юм.

## Симуляторын анхааруулга

iOS симулятор дээр ажиллуулах үед дараах лог гарч ирж магадгүй:

```
load_eligibility_plist: Failed to open ... eligibility.plist: No such file or directory
```

Энэ нь симуляторын Touch ID/Face ID дэд системээс үүдэлтэй бөгөөд аппд нөлөөлөхгүй. Derived data-гаа цэвэрлэх эсвэл симуляторыг reset хийхэд энэхүү анхааруулга алга болно.
