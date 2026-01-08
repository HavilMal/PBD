import javax.swing.*;
import java.awt.*;

class Model {
    private final Integer value;
    Model(Integer value) {
        this.value = value;
    }

    public Integer getValue() {
        return value;
    }
}

sealed abstract class Update {

    static final class Clear extends Update {}
    static final class Multiply extends Update {
        private final Integer value;
        Multiply(Integer value) {
            this.value = value;
        }

        public int getValue() {
            return value;
        }
    }
}

public class MVUApp {
    private Model model;
    private final JTextField outputField = new JTextField(20);

    public MVUApp() {
        this.model = new Model(1);
        initUI();
    }

    private void dispatch(Update update) {
        this.model = switch (update) {
            case Update.Multiply u -> new Model(u.getValue() * this.model.getValue());
            case Update.Clear c -> new Model(1);
        };

        render();
    }

    private void render() {
        outputField.setText(model.getValue().toString());
    }

    private void initUI() {
        JFrame frame = new JFrame("Calculator");

        JLabel inputLabel = new JLabel("Input:");
        JTextField inputField = new JTextField(20);

        JButton multiplyButton = new JButton("*");
        multiplyButton.addActionListener(e -> this.dispatch(new Update.Multiply(Integer.parseInt(inputField.getText()))));

        JButton clearButton = new JButton("Clear");
        clearButton.addActionListener(e -> this.dispatch(new Update.Clear()));

        JLabel totalLabel= new JLabel("Total:");

        frame.setLayout(new FlowLayout());
        frame.add(inputLabel);
        frame.add(inputField);
        frame.add(multiplyButton);
        frame.add(totalLabel);
        outputField.setEditable(false);
        frame.add(outputField);
        frame.add(clearButton);

        frame.pack();
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setVisible(true);

    }
}
