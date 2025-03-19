DateTime maxTimestamp(DateTime t1, DateTime t2) => t1.isAfter(t2) ? t1 : t2;

DateTime minTimestamp(DateTime t1, DateTime t2) => t1.isBefore(t2) ? t1 : t2;