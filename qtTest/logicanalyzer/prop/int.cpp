/*
 * This file is part of the PulseView project.
 *
 * Copyright (C) 2013 Joel Holdsworth <joel@airwebreathe.org.uk>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, see <http://www.gnu.org/licenses/>.
 */

/*
 * Copyright (c) 2020 Analog Devices Inc.
 *
 * This file is part of Scopy
 * (see http://www.github.com/analogdevicesinc/scopy).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */


#include <cassert>
#include <cstdint>

#include <QDebug>
#include <QSpinBox>


#include "int.hpp"

using boost::optional;
using std::max;
using std::min;
using std::pair;

namespace adiscope {
namespace prop {

Int::Int(QString name,
	QString desc,
	QString suffix,
	optional< pair<int64_t, int64_t> > range,
	Getter getter,
	Setter setter) :
	Property(name, desc, getter, setter),
	suffix_(suffix),
	range_(range),
	spin_box_(nullptr)
{
}

QWidget* Int::get_widget(QWidget *parent, bool auto_commit)
{
	int64_t range_min = 0;
	uint64_t range_max = 0;

	if (spin_box_)
		return spin_box_;

	if (!getter_)
		return nullptr;

	try {
		value_ = getter_();
    } catch (const std::exception &e) {
		qWarning() << tr("Querying config key %1 resulted in %2").arg(name_, e.what());
		return nullptr;
	}

	GVariant *value = value_.gobj();
	if (!value)
		return nullptr;

	spin_box_ = new QSpinBox(parent);
	spin_box_->setSuffix(suffix_);

	const GVariantType *const type = g_variant_get_type(value);
	assert(type);

	if (g_variant_type_equal(type, G_VARIANT_TYPE_BYTE)) {
		range_min = 0, range_max = UINT8_MAX;
	} else if (g_variant_type_equal(type, G_VARIANT_TYPE_INT16)) {
		range_min = INT16_MIN, range_max = INT16_MAX;
	} else if (g_variant_type_equal(type, G_VARIANT_TYPE_UINT16)) {
		range_min = 0, range_max = UINT16_MAX;
	} else if (g_variant_type_equal(type, G_VARIANT_TYPE_INT32)) {
		range_min = INT32_MIN, range_max = INT32_MAX;
	} else if (g_variant_type_equal(type, G_VARIANT_TYPE_UINT32)) {
		range_min = 0, range_max = UINT32_MAX;
	} else if (g_variant_type_equal(type, G_VARIANT_TYPE_INT64)) {
		range_min = INT64_MIN, range_max = INT64_MAX;
	} else if (g_variant_type_equal(type, G_VARIANT_TYPE_UINT64)) {
		range_min = 0, range_max = UINT64_MAX;
	} else {
		// Unexpected value type.
		assert(false);
	}

	// @todo sigrok supports 64-bit quantities, but Qt does not have a
	// standard widget to allow the values to be modified over the full
	// 64-bit range on 32-bit machines. To solve the issue we need a
	// custom widget.

	range_min = max(range_min, (int64_t)INT_MIN);
	range_max = min(range_max, (uint64_t)INT_MAX);

	if (range_)
		spin_box_->setRange((int)range_->first, (int)range_->second);
	else
		spin_box_->setRange((int)range_min, (int)range_max);

	update_widget();

	if (auto_commit)
		connect(spin_box_, SIGNAL(valueChanged(int)),
			this, SLOT(on_value_changed(int)));

	return spin_box_;
}

void Int::update_widget()
{
	if (!spin_box_)
		return;

	try {
		value_ = getter_();
    } catch (const std::exception &e) {
		qWarning() << tr("Querying config key %1 resulted in %2").arg(name_, e.what());
		return;
	}

	GVariant *value = value_.gobj();
	assert(value);

	const GVariantType *const type = g_variant_get_type(value);
	assert(type);

	int64_t int_val = 0;

	if (g_variant_type_equal(type, G_VARIANT_TYPE_BYTE)) {
		int_val = g_variant_get_byte(value);
	} else if (g_variant_type_equal(type, G_VARIANT_TYPE_INT16)) {
		int_val = g_variant_get_int16(value);
	} else if (g_variant_type_equal(type, G_VARIANT_TYPE_UINT16)) {
		int_val = g_variant_get_uint16(value);
	} else if (g_variant_type_equal(type, G_VARIANT_TYPE_INT32)) {
		int_val = g_variant_get_int32(value);
	} else if (g_variant_type_equal(type, G_VARIANT_TYPE_UINT32)) {
		int_val = g_variant_get_uint32(value);
	} else if (g_variant_type_equal(type, G_VARIANT_TYPE_INT64)) {
		int_val = g_variant_get_int64(value);
	} else if (g_variant_type_equal(type, G_VARIANT_TYPE_UINT64)) {
		int_val = g_variant_get_uint64(value);
	} else {
		// Unexpected value type.
		assert(false);
	}

	spin_box_->setValue((int)int_val);
}

void Int::commit()
{
	assert(setter_);

	if (!spin_box_)
		return;

	GVariant *new_value = nullptr;
	const GVariantType *const type = g_variant_get_type(value_.gobj());
	assert(type);

	if (g_variant_type_equal(type, G_VARIANT_TYPE_BYTE))
		new_value = g_variant_new_byte(spin_box_->value());
	else if (g_variant_type_equal(type, G_VARIANT_TYPE_INT16))
		new_value = g_variant_new_int16(spin_box_->value());
	else if (g_variant_type_equal(type, G_VARIANT_TYPE_UINT16))
		new_value = g_variant_new_uint16(spin_box_->value());
	else if (g_variant_type_equal(type, G_VARIANT_TYPE_INT32))
		new_value = g_variant_new_int32(spin_box_->value());
	else if (g_variant_type_equal(type, G_VARIANT_TYPE_UINT32))
		new_value = g_variant_new_uint32(spin_box_->value());
	else if (g_variant_type_equal(type, G_VARIANT_TYPE_INT64))
		new_value = g_variant_new_int64(spin_box_->value());
	else if (g_variant_type_equal(type, G_VARIANT_TYPE_UINT64))
		new_value = g_variant_new_uint64(spin_box_->value());
	else {
		// Unexpected value type.
		assert(false);
	}

	assert(new_value);

	value_ = Glib::VariantBase(new_value);

	setter_(value_);
}

void Int::on_value_changed(int)
{
	commit();
}

}  // namespace prop
}  // namespace pv
