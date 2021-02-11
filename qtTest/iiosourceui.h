#ifndef IIOSOURCEUI_H
#define IIOSOURCEUI_H


#include <mainwindow.h>
#include <QWidget>

namespace Ui {
class IioSourceUi;
}

class IioSourceUi : public QWidget
{
	Q_OBJECT

public:
	explicit IioSourceUi(adiscope::DataSource *ds, QWidget *parent = nullptr);
	~IioSourceUi();

private Q_SLOTS:
	void on_pushButton_clicked();

private:
	Ui::IioSourceUi *ui;
	adiscope::DataSource *ds;
};

#endif // IIOSOURCEUI_H
