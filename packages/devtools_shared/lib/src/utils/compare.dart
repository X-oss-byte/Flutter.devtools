// Copyright 2022 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid-dynamic

mixin CompareMixin implements Comparable {
  bool operator <(other) {
    return compareTo(other) < 0;
  }

  bool operator >(other) {
    return compareTo(other) > 0;
  }

  bool operator <=(other) {
    return compareTo(other) <= 0;
  }

  bool operator >=(other) {
    return compareTo(other) >= 0;
  }
}
