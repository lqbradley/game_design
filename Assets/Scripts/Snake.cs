using UnityEngine;
using UnityEngine.InputSystem;
using System.Collections.Generic;
using UnityEngine.UIElements;
using UnityEngine.SceneManagement;

public class Snake : MonoBehaviour
{
    private Vector2 _direction = Vector2.right;
    public BoxCollider2D gridArea;
    private List<Transform> _segments = new List<Transform>();
    private Button restartButton;
    public int initialSize = 4;
    public GameObject livesCounter;
    public GameObject foodSpawner;
    public UIDocument uiDocument;
    private float score = 0f;
    private Label scoreText;
    private bool isGameOver = false;
    public GameObject gameOverScreen;

    
   

    public GameObject segmentPrefab;
    private float elaspedTime = 0f;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {   
        _segments.Add(this.transform); 
        for (int i = 1; i < initialSize; i++) 
        { 
            Grow();
        }
        score = 0f;
        this.transform.position = Vector3.zero; 
        OnEnable();
        livesCounter.GetComponent<LivesCounter>().AddLife(livesCounter.GetComponent<LivesCounter>()._maxNumOfLives);
        restartButton = uiDocument.rootVisualElement.Q<Button>("RestartButton");
        restartButton.style.display = DisplayStyle.None;
        restartButton.clicked += ResetState;
        scoreText = uiDocument.rootVisualElement.Q<Label>("ScoreLabel"); 
        isGameOver = false;
        gameOverScreen.SetActive(false);
    }

    // Update is called once per frame
    void Update()
    {
        if (Keyboard.current.wKey.wasPressedThisFrame && _direction != Vector2.down && !isGameOver)
        {
            _direction = Vector2.up;
            this.transform.rotation = Quaternion.Euler(0, 0, 180);
            
        }
        else if (Keyboard.current.sKey.wasPressedThisFrame && _direction != Vector2.up && !isGameOver)
        {
            _direction = Vector2.down;
            this.transform.rotation = Quaternion.Euler(0, 0, 0);
        }
        else if (Keyboard.current.aKey.wasPressedThisFrame && _direction != Vector2.right && !isGameOver )
        {
            _direction = Vector2.left;
            this.transform.rotation = Quaternion.Euler(0, 0, 270);
        }
        else if (Keyboard.current.dKey.wasPressedThisFrame && _direction != Vector2.left && !isGameOver)
        {
            _direction = Vector2.right;
            this.transform.rotation = Quaternion.Euler(0, 0, 90);
        }

        scoreText.text = "Score: " + score;
    
        
    }

    // important for physics related updates, it is called at a fixed time interval
    void FixedUpdate()
    {   
        for (int i = _segments.Count - 1; i > 0; i--) 
        {   
            _segments[i].position = _segments[i-1].position;
        }
        this.transform.position = new Vector3(
            Mathf.Round(this.transform.position.x) + _direction.x,
            Mathf.Round(this.transform.position.y) + _direction.y,
            1.0f
        );

        // if it goes off screen
    
        if (this.transform.position.x < gridArea.bounds.min.x || this.transform.position.x > gridArea.bounds.max.x ||
            this.transform.position.y < gridArea.bounds.min.y || this.transform.position.y > gridArea.bounds.max.y)
        {
            livesCounter.GetComponent<LivesCounter>().RemoveLife(livesCounter.GetComponent<LivesCounter>()._maxNumOfLives);
            livesCounter.GetComponent<LivesCounter>().UpdateDisplay(); 
        }
    
    }
    // void FixedUpdate()
    // {   
    //     this.transform.position = new Vector3(
    //         Mathf.Round(this.transform.position.x) + _direction.x,
    //         Mathf.Round(this.transform.position.y) + _direction.y,
    //         1.0f
    //     );
    //     if (_segments.Count > 1)
    //     {
    //     Vector3 changeDirection = RemoveDiagonal(_direction * 2.4f);
    //     Vector3 targetPosition = new Vector3(
    //             Mathf.Round(_segments[1].position.x + changeDirection.x),
    //             Mathf.Round(_segments[1].position.y + changeDirection.y),
    //             1.0f);
    //      _segments[1].position = targetPosition;
    //     }

    //     // makes it so the segments follow the ones in front of it
    //     for (int i = _segments.Count - 1; i > 1; i--) 
    //     {   
    //         Vector3 direction = (_segments[i-1].position - _segments[i].position).normalized;
    //         Vector3 change = RemoveDiagonal(direction * 2.2f);
    //         Vector3 targetPos = new Vector3(
    //             Mathf.Round(_segments[i-1].position.x - change.x),
    //             Mathf.Round(_segments[i-1].position.y - change.y),
    //             1.0f);
    //          Debug.Log(_segments[i-1].forward);
    //          //_segments[i].position = _segments[i-1].position;
    //          _segments[i].position = targetPos;
    //          Debug.Log("Segment " + i + " position: " + _segments[i].position);
            
    //     }  
    // }


    private Vector3 RemoveDiagonal(Vector3 inputVector)
    {
        float X = inputVector.x;
        float Y = inputVector.y;
        if (X*X > Y*Y){
            return new Vector3 (X,0,0);
        } else {
            return new Vector3 (0,Y,0);
        }

    }

    

    private Vector3 ReturnNewPosition(Vector3 lastPosition)
    {
        if (_segments.Count > 1)
        {   
            Vector3 direction = (_segments[_segments.Count - 1].position - _segments[_segments.Count - 2].position).normalized;
            Vector3 change = RemoveDiagonal(direction * 2.2f);
            Vector3 newPosition = new Vector3(
                Mathf.Round(lastPosition.x - change.x),
                Mathf.Round(lastPosition.y - change.y),
                1.0f
            );
            return newPosition;
        } else 
        {   
            Vector3 direction = _direction.normalized;
            Vector3 change = RemoveDiagonal(direction * 2.4f);
             Vector3 newPosition = new Vector3(
                Mathf.Round(lastPosition.x - change.x),
                Mathf.Round(lastPosition.y - change.y),
                1.0f
            );
            return newPosition;
        }
    }


    void Grow()
    {
        //Vector3 lastPosition = _segments[_segments.Count - 1].position;
        
        Transform segment = Instantiate(this.segmentPrefab).transform;
        
        // segment.position = ReturnNewPosition(lastPosition);
        segment.position = _segments[_segments.Count - 1].position;
        _segments.Add(segment);
        score += 1f;
    }
    private void ResetState() 
    {   
        // for (int i = 1; i < _segments.Count; i++) 
        // { 
        //     Destroy(_segments[i].gameObject); 
        // } 
        // _segments.Clear(); // clears the list 
        // _segments.Add(this.transform); 
        // for (int i = 1; i < initialSize; i++) 
        // { 
        //     Grow();
        // }
        // this.transform.position = Vector3.zero; 
        // OnEnable();
        // livesCounter.GetComponent<LivesCounter>().AddLife(livesCounter.GetComponent<LivesCounter>()._maxNumOfLives);
        SceneManager.LoadScene(SceneManager.GetActiveScene().name);
}

        


     private void OnTriggerEnter2D(Collider2D other)
    {
        if (other.tag == "Food")
        {
            Grow();

        } 
        else if (other.tag == "Healing")
        {
            Grow();
            foodSpawner.GetComponent<FoodSpawner>().SpawnFood();
            LivesCounter livesCounterComponent = livesCounter.GetComponent<LivesCounter>();
            livesCounterComponent.AddLife(1);
            livesCounterComponent.UpdateDisplay();
        }
        else if (other.tag == "Poison") {
            LivesCounter livesCounterComponent = livesCounter.GetComponent<LivesCounter>();
            livesCounterComponent.RemoveLife(1);
            livesCounterComponent.UpdateDisplay();
            foodSpawner.GetComponent<FoodSpawner>().SpawnHealing();
        }
        else if (other.tag == "Obstacle" || other.tag == "InstantDeath")
        {
            livesCounter.GetComponent<LivesCounter>().RemoveLife(livesCounter.GetComponent<LivesCounter>()._maxNumOfLives);
            livesCounter.GetComponent<LivesCounter>().UpdateDisplay();        }
    }
    private void OnEnable()
    {
        if (livesCounter != null)
        {
            livesCounter.GetComponent<LivesCounter>().OutOfLives.AddListener(OnOutOfLives);
        }
    }

    private void OnDisable()
    {
        if (livesCounter != null)
        {
            livesCounter.GetComponent<LivesCounter>().OutOfLives.RemoveListener(OnOutOfLives);
        }
    }
    private void OnOutOfLives()
    {
        restartButton.style.display = DisplayStyle.Flex;
        this._direction = Vector2.zero;
        isGameOver = true;
        gameOverScreen.SetActive(true);
        // ResetState();
    
    }

  
}
