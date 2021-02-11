#ifndef WAVSOURCEUI_H
#define WAVSOURCEUI_H

#include <mainwindow.h>
#include <QWidget>

namespace Ui {
class WavSourceUi;
}

class WavSourceUi : public QWidget
{
	Q_OBJECT

public:
	explicit WavSourceUi(adiscope::DataSource *ds, QWidget *parent = nullptr);
	~WavSourceUi();

private Q_SLOTS:
	void on_pushButton_2_clicked();
	void on_pushButton_clicked();

private:
	Ui::WavSourceUi *ui;
	adiscope::DataSource *ds;
};

#endif // WAVSOURCEUI_H
